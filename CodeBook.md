## CodeBook

```{r readtidydata, echo=FALSE, message=FALSE}

suppressWarnings({
require(data.table)
require(kableExtra)
})
codebook <- data.table(Variable = colnames(tidy),
                       Description = NA_character_)

codebook[Variable == 'subject', 
         Description := 'Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30.']

codebook[Variable == 'activity_label', 
         Description := 'Activity performed by the subject.']

codebook[!(Variable %in% c('subject', 'activity_label')), Description := paste0('Mean of ', Variable)]
codebook
knitr::kable(d,
             caption = paste("Code Book"),
             booktabs = TRUE) %>%
kableExtra::kable_styling(font_size = 12)
```
  