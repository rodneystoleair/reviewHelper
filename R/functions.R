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

llm_inference = function(prompt,
                         research_question,
                         title,
                         abstract,
                         model_name){
  prompt_relevance = prompt |> 
    glue::glue(research_question, title, abstract)
  inference = generate(model, prompt_relevance, output = 'text')
  return(inference)
}
