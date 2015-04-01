module Transforms

  YES_NO = { set: 'Yes',
             clear: 'No',
             true => 'Yes',
             false => 'No',
             'Yes' => 'Yes',
             'No' => 'No'
  }

  TRUE_FALSE = { set: true,
                 clear: false,
                 true => true,
                 false => true,
                 'Yes' => true,
                 'No' => false
  }

  ON_OFF = { set: 'on', clear: 'off' }

  CAN = { 'can ' => :should, 'can\'t ' => :should_not }

  CHECK = { set: true, clear: false }

  MONTHS = { 'TEMPORARY EMPLOYEE' => 1,
             'SUMMER EMPLOYEE' => 3,
             '9M DURATION' => 9,
             '10M DURATION' => 10,
             '11M DURATION' => 11,
             '12M DURATION' => 12
  }

end