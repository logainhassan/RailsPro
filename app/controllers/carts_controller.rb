class CartsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :invalid_cart
  before_action :set_cart, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_admin_user! , :except=>[:show,:index]
  # GET /categories
  # GET /categories.json
  def index
    @carts = Cart.all
  end

  # GET /categories/1
  # GET /categories/1.json
  def show
    @cart = @current_cart

  end

  # GET /categories/new
  def new
    @cart = Cart.new
  end

  # GET /categories/1/edit
  def edit
  end

  # POST /categories
  # POST /categories.json
  def create
    @cart = Cart.new(cart_params)

    respond_to do |format|
      if @cart.save
        format.html { redirect_to @cart, notice: 'cart was successfully created.' }
        format.json { render :show, status: :created, location: @cart }
      else
        format.html { render :new }
        format.json { render json: @cart.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /categories/1
  # PATCH/PUT /categories/1.json
  def update
    respond_to do |format|
      if @cart.update(cart_params)
        format.html { redirect_to @cart, notice: 'cart was successfully updated.' }
        format.json { render :show, status: :ok, location: @cart }
      else
        format.html { render :edit }
        format.json { render json: @cart.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /categories/1
  # DELETE /categories/1.json
  def destroy 
    
    @cart = @current_cart
    @cart.destroy
    session[:cart_id] = nil
    redirect_to root_path

  end

  def make_order
    @cart = Cart.find(params[:id])
    note='Order has been created and is waiting for seller confirmation.'
    @order = Order.create(status: 'pending', buyer_id: current_admin_user.id)
    @cart.product_items.each do |item|
      @product = Product.find(item.product_id)
      @product.quantity -= item.quantity

      if @product.quantity >=0
        @product.save
        @order.order_products.create(
          status: 'pending',
          product_id: item.product_id,
          quantity: item.quantity,
          total_price: @cart.total_price
        )
        else
          note='invalid quantity'      
      end
      
    end
    @cart = @current_cart
    @cart.destroy
    session[:cart_id] = nil
    redirect_to root_path, notice: note
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cart
      @cart = Cart.find(params[:id])
    end
  

    # def cart_params
    #   params.require(:cart).permit()
    # end
    def cart_params
      params.fetch(:cart, {})
    end

    def invalid_cart
      logger.error "Attempt to access invalid cart #{params[:id]}"
      redirect_to root_path, notice: "this cart doesn't exist"
    end

end
  
