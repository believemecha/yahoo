class KeyValueStore < ApplicationRecord
    
    enum key: {
        payment_missing: 0,
    }
end