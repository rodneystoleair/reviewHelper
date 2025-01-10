# 0. Dependencies ----
library(ollamar)
library(httr2)
library(tidyverse)

# 1. PDFs handling -----
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

# Return title and abstract from a TEI XML file
tei_xml = read_xml('temp/output_request_kakzhezaebalo.xml')

title = tei2r::parseTEI(tei_xml, 'titleStmt') |> 
  stringr::str_squish()

abstract = tei2r::parseTEI(tei_xml, 'abstract') |> 
  stringr::str_squish()

# 2. Article relevance assessment ----
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

