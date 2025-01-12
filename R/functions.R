read_corpus = function(folder){
  file_paths = paste0('data/', 
                      folder,
                      '/',
                      list.files(paste0('data/', folder),
                                 'pdf$',
                                 recursive = T))
  
  file_names = file_paths |> 
    as_tibble_col('files') |> 
    separate_wider_delim(files, delim = '/', names = c('data',
                                                       'folder',
                                                       'prefix',
                                                       'file_name')) |> 
    select(file_name) |> 
    mutate(id = 1:length(file_paths)) |> 
    relocate(id)
  
  files = data.frame(
    file_names,
    paths = file_paths
  )
  
  return(files)
}

extract_tei = function(path, url, header){
  response = request(url) |> 
    req_url_path_append(header) |> 
    req_headers(
      Accept = 'application/xml'
    ) |> 
    req_body_multipart(input =
                         curl::form_file(paste0('~/Research/reviewHelper/',
                                                path))) |>
    req_perform() |> 
    resp_body_string()
  tei = read_xml(response)
  return(tei)
}

extract_title = function(tei){
  title = tei2r::parseTEI(tei, 'titleStmt') |> 
    stringr::str_squish()
  return(title)
}

extract_abstract = function(tei){
  abstract = tei2r::parseTEI(tei, 'abstract') |> 
    stringr::str_squish()
  return(abstract)
}

extract_fulltext = function(tei){
  fulltext = tei2r::parseTEI(tei, 'body') |> 
    stringr::str_squish()
  return(fulltext)
}


extract_authors = function(tei){
  all_authors = tei2r::parseTEI(tei, 'surname')
  if (length(all_authors) > 2){
    authors = paste(all_authors[1]) |> 
      paste0(' et al.')
  } else if (length(all_authors) == 1){
    authors = all_authors
  } else if (length(all_authors) == 2){
    authors = paste(all_authors, collapse = ', ')
  }
  return(authors)
}

llm_inference_relevance = function(prompt,
                                   model_name,
                                   research_question,
                                   title,
                                   abstract){
  glued_prompt = prompt |> 
    glue::glue(research_question,
               title,
               abstract)
  inference = generate(model, glued_prompt, output = 'text')
  return(inference)
}

llm_inference_fulltext = function(prompt,
                                   model_name,
                                   research_question,
                                   title,
                                   fulltext){
  glued_prompt = prompt |> 
    glue::glue(research_question,
               title,
               fulltext)
  inference = generate(model, glued_prompt, output = 'text')
  return(inference)
}
