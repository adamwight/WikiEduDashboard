React             = require 'react'
Expandable        = require '../high_order/expandable'
RevisionStore     = require '../../stores/revision_store'

getRevisions = (student_id) ->
  RevisionStore.getFiltered({ user_id: student_id })

StudentDrawer = React.createClass(
  displayName: 'StudentDrawer'
  mixins: [RevisionStore.mixin]
  getKey: ->
    'drawer_' + @props.student_id
  storeDidChange: ->
    @setState revisions: getRevisions(@props.student_id)
  getInitialState: ->
    revisions: getRevisions(@props.student_id)
  render: ->
    return <tr></tr> unless @props.is_open

    revisions = (@state.revisions || []).map (rev) ->
      details = 'Chars Added: ' + rev.characters + ', Views: ' + rev.views
      <tr key={rev.id}>
        <td>
          <p className="name">
            <a href={rev.article.url} target="_blank" className="inline">{rev.article.title}</a>
            <br />
            <small className='tablet-only-ib'>{details}</small>
          </p>
        </td>
        <td className='desktop-only-tc date'>{moment(rev.date).format('YYYY-MM-DD   h:mm A')}</td>
        <td className='desktop-only-tc'>{rev.characters}</td>
        <td className='desktop-only-tc'>{rev.views}</td>
        <td className='desktop-only-tc'>
          <a href={rev.url} target="_blank" className="inline">diff</a>
        </td>
      </tr>

    if @props.is_open && revisions.length == 0
      revisions = (
        <tr>
          <td colSpan="7" className="text-center">
            <p>This student has made no revisions</p>
          </td>
        </tr>
      )

    style =
      height: if @props.is_open then (40 + 71 * revisions.length) else 0
      transition: 'height .2s'
    className = 'drawer'
    className += if !@props.is_open then ' closed' else ''

    <tr className={className}>
      <td colSpan="7">
        <div style={style}>
          <table className='list list--striped'>
            <thead>
              <tr>
                <th>User Contributions</th>
                <th className='desktop-only-tc'>Date / Time</th>
                <th className='desktop-only-tc'>Chars Added</th>
                <th className='desktop-only-tc'>Views</th>
                <th className='desktop-only-tc'></th>
              </tr>
            </thead>
            <tbody>{revisions}</tbody>
          </table>
        </div>
      </td>
    </tr>
)

module.exports = Expandable(StudentDrawer)
