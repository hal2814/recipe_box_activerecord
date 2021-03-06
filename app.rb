require("pry")
require("bundler/setup")
Bundler.require(:default)

Dir[File.dirname(__FILE__) + '/lib/*.rb'].each { |file| require file }

get '/' do
  @recipes = Recipe.all()
  @all_tags = Tag.all()
  @tags = []
  @all_tags.each do |tag|
    @tags.push(tag.category)
  end
  @tags.uniq!
  erb(:index)
end

get '/create_recipe' do
  @recipes = Recipe.all()
  erb(:create_recipe)
end

post '/create_recipe' do
  recipe_name = params['recipe_name']
  recipe = Recipe.create({:recipe_name => recipe_name, :rating => nil})
  # rjoin = Rjoin.create({:recipe_id => recipe.id, :tag_id => nil, :step_id => nil, :ingredient_id => nil})
  @recipes = Recipe.all()
  redirect("/add_ingredients/#{recipe.id}")
end

get '/add_ingredients/:id' do
  @recipe = Recipe.find(params[:id])
  @ingredients = @recipe.ingredients
  erb(:add_ingredients)
end

post '/add_ingredients/:id' do
  recipe = Recipe.find(params[:id])
  item = params[:item]
  amount = params[:amount]
  ingredient = Ingredient.create({:item => item, :amount => amount})
  Rjoin.create({:recipe_id => recipe.id, :tag_id => nil, :step_id => nil, :ingredient_id => ingredient.id})
  redirect("/add_ingredients/#{recipe.id}")
end

get '/recipe/:id' do
  @recipe = Recipe.find(params[:id])
  @ingredients = @recipe.ingredients()
  @tags = @recipe.tags()
  @steps = @recipe.steps()
  erb(:recipe)
end

patch '/recipe/:id' do
  recipe = Recipe.find(params[:id])
  rating = params['star']
  recipe.update({:rating => rating})
  redirect("/recipe/#{recipe.id}")
end

get '/add_steps/:id' do
  @recipe = Recipe.find(params[:id])
  @steps = @recipe.steps()
  erb(:add_steps)
end

post '/add_steps/:id' do
  recipe = Recipe.find(params[:id])
  steps = recipe.steps()
  instruction = params[:instruction]
  step = Step.create({:instruction => instruction})
  Rjoin.create({:recipe_id => recipe.id, :tag_id => nil, :step_id => step.id, :ingredient_id => nil})
  redirect("/add_steps/#{recipe.id}")
end

get '/add_tags/:id' do
  @recipe = Recipe.find(params[:id])
  @tags = @recipe.tags()
  erb(:add_tags)
end

post '/add_tags/:id' do
  recipe = Recipe.find(params[:id])
  tags = recipe.tags()
  category = params[:category]
  tag = Tag.create({:category => category})
  Rjoin.create({:recipe_id => recipe.id, :tag_id => tag.id, :step_id => nil, :ingredient_id => nil})
  redirect("/add_tags/#{recipe.id}")
end

get '/tag/:category' do
  @all_tag = Tag.where("category = '#{params[:category]}'")
  @recipes = []
  @all_tag.each do |tag|
    @recipes.push(tag.recipes)
  end
  erb(:tag)
end

get '/ingredient/:id/:item' do
  @ingredient = Ingredient.find(params[:id])
  @all_ing = Ingredient.where("item = '#{@ingredient.item}'")
  # rjoin
  # @all_ing.each do |ing|
  #   rjoin.push(Rjoin.where("ingredient_id = '#{ing.id}'"))
  # end
  @recipes = []
  @all_ing.each do |ing|
    @recipes.push(ing.recipes)
  end
  erb(:ingredient)
end

get '/edit_recipe/:id' do
  @recipe = Recipe.find(params[:id])

  erb(:edit_recipe)
end

patch '/edit_recipe/:id' do
  recipe_name = params['recipe_name']
  recipe = Recipe.find(params[:id])
  recipe.update({:recipe_name => recipe_name})
  redirect("/recipe/#{recipe.id}")
end

delete '/edit_recipe/:id' do
  recipe = Recipe.find(params[:id])
  rjoins = Rjoin.where("recipe_id = '#{recipe.id}'")
  rjoins.each do |r|
    if r.ingredient_id.blank? == false
        binding.pry
      Ingredient.find(r.ingredient_id).destroy
    end
    if r.tag_id.blank? == false
      Tag.find(r.tag_id).destroy
    end
    if r.step_id.blank? == false
      Step.find(r.step_id).destroy
    end
    r.destroy
  end
  recipe.destroy
  redirect("/")
end
