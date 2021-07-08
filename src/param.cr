macro build_param(descriptions)
  module Cocaine::Param

    # {
    #   "name" => "index",
    #   "path" => "/",
    #   "verb" => "GET",
    #   "handler" => Controller.index
    # }

    {% for description in descriptions %}
      {% if description["path"].includes? ':' %}
        {%  %}
        {% path = description["path"].split %}


      {% end %}
    {% end %}
  end
end
