context("pocket_get")


POCKET_TEST_CONSUMER_KEY <- "fakekey"
POCKET_TEST_ACCESS_TOKEN <- "faketoken"


test_that("empty consumer key causes error", {
  expect_error(pocket_get(
    access_token = POCKET_TEST_ACCESS_TOKEN, consumer_key = ""
  ),
  regexp = "^POCKET_CONSUMER_KEY does not exist as environment variable. "
  )
})

test_that("empty access token causes error", {
  expect_error(pocket_get(
    access_token = "", consumer_key = POCKET_TEST_CONSUMER_KEY
  ),
  regexp = "^POCKET_ACCESS_TOKEN does not exist as environment variable"
  )
})

test_that("invalid tag value causes error", {
  expect_error(pocket_get(access_token = POCKET_TEST_ACCESS_TOKEN, consumer_key = POCKET_TEST_CONSUMER_KEY, tag = c("more", "than", "one")),
    regexp = "^The tag argument can only be a character string."
  )

  test_that("invalid favorite value causes error", {
    expect_error(pocket_get(
      access_token = POCKET_TEST_ACCESS_TOKEN, consumer_key = POCKET_TEST_CONSUMER_KEY,
      favorite = "stringisnotvalid"
    ),
    regexp = "^The favorite argument can only be"
    )
  })
})

test_that("invalid item_type value causes error", {
  expect_error(pocket_get(
    access_token = POCKET_TEST_ACCESS_TOKEN, consumer_key = POCKET_TEST_CONSUMER_KEY,
    item_type = "typenotexist"
  ),
  regexp = "^The item_type argument can only be"
  )
})

# get-86fba0-POST.R
with_mock_api({
  test_that("invalid access token causes error", {
    expect_error(pocket_get(access_token = "dsffkwejrl", consumer_key = POCKET_TEST_CONSUMER_KEY),
      regexp = "\n401 Unauthorized: A valid access token"
    )
  })
})

# get-40608f-POST.json
with_mock_api({
  test_that("return value is data frame", {
    return_value <- pocket_get(consumer_key = POCKET_TEST_CONSUMER_KEY, access_token = POCKET_TEST_ACCESS_TOKEN)
    expect_s3_class(return_value, "data.frame")
    expect_gt(nrow(return_value), 0)
  })
})