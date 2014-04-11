@Contributron ||= {}

Handlebars.registerHelper "pr_link", ->
  new Handlebars.SafeString("#{@user.login} - <a href='" + @html_url + "'>"+ @title + "</a>")


class Contributron.pull_request

  constructor: ->

  get_closed: (repo, org, organization_id) ->

    $.getJSON('/dashboard/pull_requests/load_closed',
      ext_repo: repo
      ext_org: org
      org_id: organization_id
    ).done (data) ->
      $('.loading').remove()
      console.log data
      $("#closed").html HandlebarsTemplates.pull_requests items: data
      return





