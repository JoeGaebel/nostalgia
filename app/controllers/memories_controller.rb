class MemoriesController < ApplicationController
  before_action :ensure_allowed_access, only: [:show, :edit]
  before_action :authenticate_user!, only: [:index, :new, :edit]

  def edit
    @page_title = "Edit Memory"
  end

  def new
    @memory = current_user.memories.create({ name: "New Memory" })
    redirect_to edit_memory_path(@memory)
  end

  def show
    @page_title = @memory.name
  end

  def index
    @page_title = "Memories"
    @memories = current_user.memories.paginate({
      page: params[:page],
      per_page: 5
    })
  end

  def destroy
    memory = current_user.memories.find_by(id: params[:id])
    memory.destroy if memory
    redirect_to memories_path
  end

  def set_details
    memory = current_user.memories.find_by(id: params[:id])

    if memory.blank?
      render_not_found
      return
    end

    memory.name = sanitize(params[:name]) if params[:name].present?
    memory.description = sanitize(params[:description]) if params[:description].present?
    memory.private = params[:private] if is_boolean?(params[:private])

    if memory.save
      render json: { name: memory.name, description: memory.description, private: memory.private }, status: :created
    else
      render_model_errors(memory)
    end
  end

  private

  def ensure_allowed_access
    memory = Memory.find_by(id: params[:id])
    not_found if memory.blank?

    if memory.private
      if user_signed_in? && memory.user_id == current_user.id
        set_instance_vars(memory)
      else
        redirect_to_home
      end
    else
      set_instance_vars(memory)
    end
  end

  def redirect_to_home
    flash[:info] = "This memory is private, please log in."
    redirect_to root_path
  end

  def set_instance_vars(memory)
    @memory = memory
    @memory_json = memory.to_builder.target!
  end

  def memory_params
    params.require(:memory).permit(:name, :description, :private)
  end

  def build_spheres(memory, sphere_params)
    sphere_params.each do |_, sphere_attrs|
      sphere = memory.spheres.build
      sphere.panorama = sphere_attrs[:panorama]
      sphere.caption = sphere_attrs[:caption]
      sphere.save
    end
  end
end
