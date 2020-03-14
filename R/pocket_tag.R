#' pocket_tag
#' @description modify the tags of the items in pocket.
#' @param item_ids character vector. Pocket item ids you want to modify the tags for.
#' @param action_name character vector. The kind of tag action you want to undertake. Possible values: 'tags_add', 'tags_remove', 'tags_replace', 'tags_clear', 'tag_rename', or 'tag_delete'.
#' @param tags character vector. The names of the tags to work with the chosen action.
#' @param old_new character vector with two elements. Compulsory if action = rename. First element = old tag, second = new tag.
#' @export
pocket_tag <- function(item_ids = NULL, action_name, tags = NULL, old_new = NULL) {

  # Pre-process tags comma separated string
  tags <- collapse_to_comma_separated_(tags)

  # Validity checks
  stop_for_invalid_tag_action_(item_ids = item_ids, action_name = action_name, tags = tags, old_new = old_new)

  if (action_name %in% c("tags_replace", "tags_remove", "tags_add", "tags_clear")) {
    action_list <- item_ids %>% purrr::map(
      action_name = action_name,
      tags = tags,
      .f = gen_action_
    )

    action_results <- pocket_modify(action_list)

    return(invisible(action_results))
  }

  # Processing
  if (action_name == "tag_rename") {
    old_tag <- old_new[1]

    new_tag <- old_new[2]

    action_list <- action_name %>% purrr::map(
      old_tag = old_tag,
      new_tag = new_tag,
      .f = gen_tag_action_
    )

    actions_json <- jsonlite::toJSON(action_list, auto_unbox = TRUE)

    res <- pocket_post_("send",
      Sys.getenv("POCKET_CONSUMER_KEY"),
      Sys.getenv("POCKET_ACCESS_TOKEN"),
      actions = actions_json
    )

    pocket_stop_for_status_(res)
    message(glue::glue("Successfully renamed tag '{old_tag}' for '{new_tag}'."))
  }

  if (action_name == "tag_delete") {
    action_list <- action_name %>% purrr::map(
      tag = tags,
      .f = gen_tag_action_
    )

    actions_json <- jsonlite::toJSON(action_list, auto_unbox = TRUE)

    res <- pocket_post_("send",
      Sys.getenv("POCKET_CONSUMER_KEY"),
      Sys.getenv("POCKET_ACCESS_TOKEN"),
      actions = actions_json
    )

    pocket_stop_for_status_(res)
    message(glue::glue("Successfully removed tag '{tags}'."))
  }
}



#' gen_tag_action_
#' @description generate an action list element for a given action name
#' @param action_name character. Name of Pocket action as string.
#' @param ... additional named arguments to be added to the action list.
#' @return list
gen_tag_action_ <- function(action_name, ...) {
  return(list(
    action = action_name,
    time = as.POSIXct(Sys.time()),
    ...
  ))
}



stop_for_invalid_tag_action_ <- function(item_ids, action_name, tags, old_new) {
  actions <- c("tags_add", "tags_remove", "tags_replace", "tags_clear", "tag_rename", "tag_delete")

  if (!action_name %in% actions) {
    stop("Tag actions can be only be: 'tags_add', 'tags_remove', 'tags_replace', 'tags_clear', 'tag_rename', or 'tag_delete'.")
  }

  if (action_name != "tag_rename" & !is.null(old_new)) {
    stop("Only provide a value for old_new when your action is 'tag_rename'.")
  }

  if (is.null(item_ids) & !action_name %in% c("tag_delete", "tag_rename")) {
    stop("If your action_name is not 'tag_delete' or 'tag_rename', you need to provide an item_id.")
  }

  if (action_name == "tag_delete" & length(tags) > 1) {
    stop("For 'tag_delete', you can only specify an atomic vector of one tag.")
  }

  if (action_name == "tag_rename" & length(old_new) != 2) {
    stop("If your action is 'tag_rename', you need to provide a vector for 'old_new', format: c('old tag', 'new tag').")
  }

  if (action_name == "tags_clear" & !is.null(tags)) {
    stop("If your action is 'tags_clear', you must not provide tags.")
  }
}