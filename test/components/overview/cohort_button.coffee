require '../../testHelper'
McFly = require 'mcfly'
Flux = new McFly()
rewire = require 'rewire'

describe 'CohortButton', ->
  CohortButton = rewire '../../../app/assets/javascripts/components/overview/cohort_button'
  CohortStore = rewire '../../../app/assets/javascripts/stores/cohort_store'

  it 'renders a plus button', ->
    TestButton = ReactTestUtils.renderIntoDocument(
      <CohortButton
        cohorts=[]
        show=true
      />
    )
    renderedButton = ReactTestUtils.findRenderedDOMComponentWithClass(TestButton, 'plus')
