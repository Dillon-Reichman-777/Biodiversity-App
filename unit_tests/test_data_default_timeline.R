source("data_processing_functions.R")

context("Testing for edge cases in the data_default_timeline() function")

test_that("length of columns in pivot table add up to what is expected",{
  expect_equal(data_default_timeline(poland_species_data)[[2]],data_default_timeline(poland_species_data)[[3]])
})