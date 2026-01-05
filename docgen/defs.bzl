"""Public API for docgen rules."""

load("//docgen/private:docs.bzl", _docs = "docs")
load("//docgen/private:docs_action.bzl", _docs_action = "docs_action", _docs_action_impl = "docs_action_impl")
load("//docgen/private:docs_index.bzl", _docs_index = "docs_index")
load("//docgen/private:docs_link.bzl", _docs_link = "docs_link")
load("//docgen/private:git_last_updated_timestamps.bzl", _git_last_updated_timestamps = "git_last_updated_timestamps")
load("//docgen/private:markdown.bzl", _markdown_action = "markdown_action", _markdown_rule = "markdown")
load("//docgen/private:markdown_add_last_updated.bzl", _markdown_add_last_updated = "markdown_add_last_updated")
load("//docgen/private:mkdocs_build.bzl", _mkdocs_build = "mkdocs_build")
load("//docgen/private:mkdocs_config.bzl", _mkdocs_config = "mkdocs_config")
load("//docgen/private:mkdocs_serve.bzl", _mkdocs_serve = "mkdocs_serve")
load("//docgen/private:providers.bzl", _DocsLinkInfo = "DocsLinkInfo", _DocsProviderInfo = "DocsProviderInfo", _MarkdownInfo = "MarkdownInfo")

docs = _docs
docs_action = _docs_action
docs_action_impl = _docs_action_impl
docs_index = _docs_index
docs_link = _docs_link
markdown_add_last_updated = _markdown_add_last_updated

def markdown(name, **kwargs):
    _markdown_rule(name = name, **kwargs)
    native.filegroup(name = name + ".files", srcs = [name], tags = ["markdown"])

markdown_action = _markdown_action
mkdocs_build = _mkdocs_build
mkdocs_config = _mkdocs_config
mkdocs_serve = _mkdocs_serve
git_last_updated_timestamps = _git_last_updated_timestamps
DocsProviderInfo = _DocsProviderInfo
DocsLinkInfo = _DocsLinkInfo
MarkdownInfo = _MarkdownInfo
