library(ollamar)
library(httr2)
library(pdftools)
library(tidyverse)
library(tm)

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
  select(file_name)

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

response = request(base_url) |> 
  req_url_path_append(header_document) |> 
  req_headers(
    Accept = 'application/xml'
  ) |> 
  req_body_multipart(input =
                       curl::form_file('~/Research/reviewHelper/data/recons/234/eeww.pdf')) |>
  req_perform() |> 
  resp_body_string()
response
write(response, 'temp/output_request_kakzhezaebalo.xml')

perform_request = response_form |> 
  req_perform()







research_question = readline('Write your research question: ')

# LLM request
test_connection()

prompt_relevance = readLines('data/prompts/prompt_relevance.txt') |> 
  paste0(collapse = '\n') |> 
  glue()
prompt_relevance

response = generate('llama3.2', prompt_relevance, output = 'text') |> 
  write(file = 'temp/test_llama_output.txt')

list_models()

