def choose(weight)
  # This is a standard weighted randomization method, it is used to indicate the probability of a specific outcome.
  # We will use it later to define the chances of a successful ride match, and the chances of churn.
  chance = rand()
  chance <= weight / 100.0
end

def ride_request(match, lyft_take)
  # This method defines that every time a ride is requested, if there is a match, we should add the Lyft take rate to the yearly revenue (sum).
  # The probability of a successful match is indicated in our loop below.
  if match == true
    $yearly_revenue += lyft_take
  end
end


def lose_rider(match, rider_churn)
  # This method defines riders' churn. Specifically, a 10% chance of losing a rider if a match is successful, and a 33% chance in case of no match.
  # I'm calling an 'acquire_new_rider' method every time we lose a rider, assuming that we want to keep a stable operation, and won't allow the reduction of our customer base.
  if match == true
    rider_churn = choose(10)
  else
    rider_churn = choose(33)
  end
  rider_churn == true ? $rider_churn_count += 1 : 0
  return rider_churn
end

def acquire_new_rider()
  # For simplification, I'm considering acquiring a new rider for each one we lose, and disregarding a growth scenario on purpose.
    $rider_churn_count % 100 == 0 && $cac < 20 ? $cac += 0.5 : 0
    $invested_budget += $cac
end

def lose_driver(driver_churn)
  # This method defines drivers' churn. Specifically, a 5% chance of losing a driver.
  # I'm calling an 'acquire_new_driver' method every time we lose a driver.
  driver_churn = choose(5)
  driver_churn == true ? $driver_churn_count += 1 : 0
end

def acquire_new_driver()
  # For simplification, I'm considering acquiring a new driver for each one we lose, and disregarding a growth scenario on purpose.
    $invested_budget += $driver_cac
end

def run(monthly_riders, rider_churn, driver_churn, lyft_take)
  # This is the loop that will run 12 times, to simulate a 12-month period.
  # I've established an 'if' condition that sets a 60% chance of a successful match in case our take rate is set at $6, and 93% in case our take rate is set at $3.
  # All variables are initialized at 0 value, except for CAC, since the smallest possible CAC we know is $10.
  $yearly_revenue = 0
  $rider_churn_count = 0
  $invested_budget = 0
  $cac = 10
  $driver_cac = 500
  $driver_churn_count = 0

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
      driver_churn = lose_driver(driver_churn)
      driver_churn == true ? acquire_new_driver() : 0
    end
  end

  net_revenue = $yearly_revenue - $invested_budget

  return {yearly_revenue: $yearly_revenue, invested_budget: $invested_budget, net_revenue: net_revenue, rider_churn_count: $rider_churn_count}
end

lyft_take = 6
# This is where we set our take.

monthly_riders = 1000
monthly_drivers = 100
# Initialized these 2 variables at an arbitrary number. What matters for our analysis is their fluctuation throughout 12-months.
# Important to note that, since 1 rider requests 1 rider per month on average, the amount of ride requests is always equal to the amount of monthly riders.

rider_churn = false
driver_churn = false
match = false
# Initialized this variable at 'false', since we added on the methods above the chances of it becoming 'true' based on the match rate at each price.
# This is the end of the main model.

results = []
# Now that our model works, I'll just add a loop to run in n times and store results in a list, then calculate the average for a reliable estimation.

100.times do
  results_hash = run(monthly_riders, rider_churn, driver_churn, lyft_take)
  results.append(results_hash)
end
# The larger the number of times, the more statistically significant our estimation gets.

sum_net_revenue = 0
sum_invested_budget = 0
sum_yearly_revenue = 0

results.each do | result |
  sum_yearly_revenue += result[:yearly_revenue]
  sum_invested_budget += result[:invested_budget]
  sum_net_revenue += result[:net_revenue]
end

average_net_revenue = sum_net_revenue / results.size
average_yearly_revenue = sum_yearly_revenue / results.size
average_invested_budget = sum_invested_budget / results.size

puts "Estimated yearly revenue: #{average_yearly_revenue.round} | Estimated invested budget: #{average_invested_budget.round} | Estimated net revenue: #{average_net_revenue.round} "
