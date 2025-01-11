# 0. Dependencies ----
# remotes::install_github('michaelgavin/tei2r')
library(ollamar)
library(xml2)
library(httr2)
library(tidyverse)

source('R/functions.R')

# 1. PDFs handling -----
# PDF selection
project = readline('Write your article folder name: ')

file_paths = paste0('data/', 
                    project,
                    '/',
                    list.files(paste0('data/', project), 'pdf$', recursive = T))

file_names = file_paths |> 
  as_tibble_col('files') |> 
  separate_wider_delim(files, delim = '/', names = c('data',
                                                     'folder',
                                                     'prefix',
                                                     'file_name')) |> 
  select(file_name) |> 
  mutate(id = 1:length(file_paths)) |> 
  relocate(id)

# Text mining: how to pull an abstact? Using Grobid
base_url = 'http://localhost:8070/api'
header_document = '/processHeaderDocument'
is_alive = 'isalive'
check = request(base_url) |> 
  req_url_path_append(is_alive) |> 
  req_perform() |> 
  resp_body_string()

if (check == 'true') {
  print('Grobid is up and running')
} else {
  print('Grobid is disabled. Please check your container')
}

# Returning data from Grobid local server
teis = lapply(file_paths,
              extract_tei,
              url = base_url,
              header = header_document)

titles_abstracts = tibble(
  id = 1:length(teis),
  title = sapply(teis, extract_title),
  abstract = sapply(teis, extract_abstract)
) |> 
  left_join(file_names, by = 'id') |> 
  relocate(file_name, .after = 'id')

# 2. Article relevance assessment ----
research_question = readline('Write your research question: ')
model = readline('Write model name: ')

# LLM request
test_connection()

prompt = readLines('data/prompts/prompt_relevance.txt') |> 
  paste0(collapse = '\n')

relevance = c()
scores = c()
for (i in 1:length(titles_abstracts$id)) {
  article_relevance = llm_inference(prompt,
                                    research_question,
                                    titles_abstracts$title[i],
                                    titles_abstracts$abstract[i],
                                    model)
  relevance = append(relevance, article_relevance)
  score = str_extract(article_relevance, '\\d points\\b|\\d point\\b') |> 
    str_extract('\\d+') |> 
    as.numeric()
  scores = append(scores, score)
}

relevance_result = tibble(
  titles_abstracts,
  relevance,
  scores
)
