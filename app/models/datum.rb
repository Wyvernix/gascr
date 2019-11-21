class Datum < ApplicationRecord
  enum tag: { cng: 0, coal: 1, oil: 2, hhi: 3, industry: 4, reserves: 5 }
end
