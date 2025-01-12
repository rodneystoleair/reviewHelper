base_url = 'http://localhost:8070/api'
fulltext_document = '/processFulltextDocument'

extract_tei_fulltext = function(path, url, header){
  response = request(url) |> 
    req_url_path_append(header) |> 
    req_body_multipart(input =
                         curl::form_file(paste0('~/Research/reviewHelper/',
                                                path))) |>
    req_perform() |> 
    resp_body_string()
  tei = read_xml(response)
  return(tei)
}

teis = lapply(relevance_result$paths,
              extract_tei_fulltext,
              url = base_url,
              header = fulltext_document)

fulltexts = tibble(
  id = 1:length(teis),
  title = sapply(teis, extract_title),
  authors = sapply(teis, extract_authors),
  fulltext = sapply(teis, extract_fulltext)
) |> 
  left_join(files, by = 'id') |> 
  relocate(file_name, .after = 'id')

prompt = readLines('data/prompts/answering.txt') |> 
  paste0(collapse = '\n')

answers = c()
for (i in 1:length(fulltexts$id)) {
  article_relevance = llm_inference_fulltext(prompt,
                                    model,
                                    research_question,
                                    fulltexts$title[i],
                                    fulltexts$fulltext[i])
  answers = append(relevance, article_relevance)
  score = str_extract(article_relevance, '\\d points\\b|\\d point\\b') |> 
    str_extract('\\d+') |> 
    as.numeric()
  scores = append(scores, score)
}

glued_prompt = glue::glue(prompt)
glued_prompt
