def choose(weight)
  # This is a standard weighted randomization method, is is used to indicate the probability of a specific outcome.
  # We will use it later to define the chances of a successful ride match, and the chances of churn.
  chance = rand()
  chance <= weight / 100.0
end

def ride_request(match, lyft_take)
  # This method defines that every time a ride is requested, if there is a match, we should add the Lyft take rate to the yearly income (sum).
  # The probability of a successful match is indicated in our loop below.
  if match == true
    $yearly_income += lyft_take
  end
end


def lose_rider(match, rider_churn)
  # This method defines riders' churn. Specifically, a 10% chance of losing a rider if a match is successful, and a 33% chance in case of no match.
  # I'm calling an 'acquire_new_rider' method every time we lose a rider, assuming that we want to keep a stable operation, and won't allow the reduction of my customer base.
  if match == true
    rider_churn = choose(10)
  else
    rider_churn = choose(33)
  end
  rider_churn == true ? $rider_churn_count += 1 : 0
  return rider_churn
end

def acquire_new_rider()
    $rider_churn_count % 100 == 0 && $cac < 20 ? $cac += 0.5 : 0
    $invested_budget += $cac
end

def run(monthly_riders, rider_churn, lyft_take)
  $yearly_income = 0
  $rider_churn_count = 0
  $invested_budget = 0
  $cac = 10

  12.times do
    monthly_riders.times do
      if lyft_take == 6
        match = choose(60)
      elsif lyft_take == 3
        match = choose(93)
      end
      ride_request(match, lyft_take)
      rider_churn = lose_rider(match, rider_churn)
      rider_churn == true ? acquire_new_rider() : 0
    end
  end

  gross_profit = $yearly_income - $invested_budget

  puts "Yearly income: #{$yearly_income} | Invested budget: #{$invested_budget} | Rider churn count: #{$rider_churn_count} | Gross profit: #{gross_profit}"
end

lyft_take = 6
# This is where we set our take.

monthly_riders = 1000
monthly_drivers = 100
# Initialized these 2 variables at an arbitrary number. What matters for our analysis is their fluctuation throughout 12-months.
# Important to note that, since 1 rider requests 1 rider per month on average, the amount of ride requests is always equal to the amount of monthly riders.

rider_churn = false
match = false
# Initialized this variable at 'false', and will add later on the methods the chances of it becoming 'true' based on the match rate at each price.
run(monthly_riders, rider_churn, lyft_take)