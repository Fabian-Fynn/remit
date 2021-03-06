# Disable {} attribute delimiters so we don't get
# issues with "{{foo}}" AngularJS interpolation.
#
# https://github.com/slim-template/slim/pull/434

Slim::Engine.set_options attr_list_delims: {
  "(" => ")",
  "[" => "]",
}
