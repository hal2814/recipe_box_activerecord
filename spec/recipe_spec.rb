require('spec_helper')

describe(Recipe) do
  it {should have_many(:tags)}
  it {should have_many(:ingredients)}
  it {should have_many(:steps)}
end
