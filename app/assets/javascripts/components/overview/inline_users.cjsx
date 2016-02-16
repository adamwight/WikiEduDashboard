React             = require 'react'
EnrollButton      = require '../students/enroll_button'

InlineUsers = React.createClass(
  displayName: 'InlineUsers'
  render: ->
    key = @props.title + '_' + @props.role
    last_user_index = @props.users.length - 1
    user_list = @props.users.map (user, index) ->
      if user.real_name?
        extra_info = " (#{user.real_name}#{if user.email? then " / " + user.email else ""})"
      else
        extra_info = ''
      extra_info = extra_info + ', ' unless index == last_user_index

      <span key={user.wiki_id}><a href={user.user_url}>{user.wiki_id}</a>{extra_info}</span>

    user_list = if user_list.length > 0 then user_list else 'None'
    if @props.users.length > 0 || @props.editable
      inline_list = <span>{@props.title}: {user_list}</span>
    allowed = @props.role != 4 || (@props.current_user.role == 4 || @props.current_user.admin)
    button = <EnrollButton {...@props} users={@props.users} role={@props.role} key={key} inline=true allowed={allowed} show={@props.editable && allowed} />

    <div key={key}>{inline_list}{button}</div>
)

module.exports = InlineUsers
