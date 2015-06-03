React             = require 'react/addons'
StudentActions    = require '../../actions/student_actions'

StudentDrawer = React.createClass(
  displayName: 'StudentDrawer'
  render: ->
    revisions = @props.revisions.map (rev) ->
      details = 'Chars Added: ' + rev.characters + ', Views: ' + rev.views
      <tr key={rev.id}>
        <td>
          <p className="name">
            <span>{rev.article.title}</span>
            <br />
            <small className='tablet-only-ib'>{details}</small>
          </p>
        </td>
        <td className='desktop-only-tc'>{moment(rev.date).format('YYYY-MM-DD hh:mm')}</td>
        <td className='desktop-only-tc'>{rev.characters}</td>
        <td className='desktop-only-tc'>{rev.views}</td>
        <td className='desktop-only-tc'></td>
      </tr>
    style =
      height: if @props.open then (40 + 71 * @props.revisions.length) else 0
      transition: 'height .2s'

    className = 'drawer'
    className += if !@props.open then ' closed' else ''
    <tr className={className}>
      <td colSpan="6">
        <div style={style}>
          <table>
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

module.exports = StudentDrawer