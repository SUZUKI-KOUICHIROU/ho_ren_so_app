class RadioButtonOptionString < ApplicationRecord
  belongs_to :radio_button

  validates :option_string, presence: true
end
