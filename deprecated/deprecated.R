library(tm)
library(pdftools)

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
