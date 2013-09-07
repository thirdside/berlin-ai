require 'sinatra/base'

class Berlin::Standalone < Sinatra::Base
  class UnspecifiedHandler < Exception; end

  enable :logging

  def initialize
    super
    @handlers = {}
  end

  def handler_for(game_id)
    if @handlers[game_id].nil?
      klass = Berlin::AI.handler || raise(UnspecifiedHandler)
      @handlers[game_id] = klass.new
    end

    @handlers[game_id]
  end

  def release(game_id)
    @handlers.delete game_id
  end

  post '/' do
    begin
      game_id = JSON(params[:infos])['game_id']

      # Check if it's one of the four Berlin keywords
      if ['ping', 'turn', 'game_start', 'game_over'].include?(params[:action])
        logger.info "New request of type #{params[:action]} : #{params.inspect}"

        handler = handler_for(game_id)
        game = Berlin::AI::Game::Internal.create_or_update(params[:action], params[:infos], params[:map], params[:state])
        handler.game = game
        handler.map = map

        if ['ping', 'turn'].include?(params[:action])
          # Clear old moves
          game.reset!

          # Let the player decides his moves
          handler.on_turn(game)

          # Get moves from AI
          moves = game.moves.to_json

          # Log time!
          logger.info "Respond with: #{moves}"

          # Return the response to Berlin
          return moves
        elsif params[:action] == 'game_over'
          release(game_id)
        end
      else
        logger.error params.inspect
      end

      # For every other type of request, respond with 200 OK
      200
    rescue Exception => e
      logger.fatal "#{e.inspect}\n#{e.backtrace}"

      # Internal server error
      500
    end
  end
end
