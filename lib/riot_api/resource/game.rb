module RiotApi
  module Resource
    class Game < Base

      def recent(summoner_id)
        get(recent_path(summoner_id)).games
      end

      private

      def recent_path(summoner_id)
        "#{base_path(summoner_id)}/recent"
      end

      def base_path(summoner_id)
        "game/by-summoner/#{summoner_id}"
      end

    end
  end
end
