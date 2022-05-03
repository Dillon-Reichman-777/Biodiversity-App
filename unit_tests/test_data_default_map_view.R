source("data_processing_functions.R")

context("Testing for edge cases in the data_default_map_view() function")

test_that("Left join has same number of rows as the left table in the join",{
  expect_equal(data_default_map_veiw(poland_species_data)[[2]],data_default_map_veiw(poland_species_data)[[3]])
})

