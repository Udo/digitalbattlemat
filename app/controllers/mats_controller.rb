class MatsController < ApplicationController
  def create
    new_mat = BattleMats.new(params[:mat])
    new_mat.x_dimension = 10
    new_mat.y_dimension = 16
    new_mat.save
    redirect_to :action => 'index'
  end

  def destroy
    BattleMats.find(params[:id]).destroy()
    redirect_to :action => 'index'
  rescue
    # No such mat? Never mind.
    redirect_to :action => "index"
  end
  
  def index
    @mats = BattleMats.find :all
  end
  
  def new
    redirect_to :action => 'index'
  end
  
  def edit
    @mat = BattleMats.find(params[:id])

    # Fill backgrounds array
    @backgrounds = []
    begin
      Dir.foreach('public/images/textures/backgrounds') do |entry|
        if entry =~ /\.(png|jp.?g)$/i then
          @backgrounds << entry
        end
      end
    rescue
      # Means that there's just no background.
    end

    # Fill tiles array
    @tiles = []      
    begin
      Dir.foreach('public/images/textures/tiles') do |entry|
        if entry =~ /\.(png|jp.?g)$/i then
          @tiles << entry
        end
      end
    rescue
      # It's ok, just leave the array empty.
    end
  rescue
    # Might be that there is no Mat, so return
    redirect_to :action => "index"     
  end
  
  def update
    mat = BattleMats.find params[:id]
    mat.description = params[:mat][:description]
    mat.x_dimension = params[:mat][:x_dimension]
    mat.y_dimension = params[:mat][:y_dimension]
    
    # Remove "url(...)" from background argument
    if params[:mat][:background] and 
        params[:mat][:background] =~ /url\(([^)]*)\)/ then
      mat.background = $1
    end
    mat.save
    
    # Save tiles of this mat
    0.upto(params[:mat][:x_dimension].to_i - 1) do |i|
      0.upto(params[:mat][:y_dimension].to_i - 1) do |j|
        tile = BattleMatTiles.first :conditions => [
          "x_position = ? AND y_position = ? AND battle_mat_id = ?",
            i.to_s, j.to_s, params[:id]
        ]
        if nil == tile
          tile = BattleMatTiles.new
        end
        
        tile.x_position = i
        tile.y_position = j
        tile.tile_source = params[:mat][:tiles][i.to_s][j.to_s][:src]
        tile.visibility = params[:mat][:tiles][i.to_s][j.to_s][:visibility]
        tile.battle_mat_id = params[:id]
        
        tile.save
      end
    end
  rescue
    # This propably means that there's no such Mat. That's ok. We should give
    # some error handling, I guess, but we don't.
  end

  def show
    @mat = BattleMats.find_by_id(params[:id])
    render :layout => "plain"
  end
end
