require 'spec_helper'

describe RiotApi::API, :vcr do
  subject { ra = RiotApi::API.new :api_key => api_key, :region => 'euw' }
  let(:api_key)   { API_KEY }

  describe '.new' do
    it 'should return an instance when called with the essential parameters' do
      client = RiotApi::API.new :api_key => api_key, :region => 'euw'
      client.should be_instance_of(RiotApi::API)
    end

    it 'should raise an error when no api key given' do
      expect{ client = RiotApi::API.new :region => 'euw'}.to raise_error(ArgumentError, ':api_key missing')
    end

    it 'should raise an error when given an invalid region' do
      expect{ client = RiotApi::API.new :api_key => api_key, :region => 'YYZ'}.to raise_error(ArgumentError, "Invalid Region (Valid regions: 'eune','br','tr','na','euw')")
    end

    it 'should output to stdout with debug parameter' do
      client = RiotApi::API.new :api_key => api_key, :region => 'euw', :debug => true

      printed = capture_stdout do
        client.summoner.name 'BestLuxEUW'
      end
      expect(printed).to include 'Started GET request to: http://prod.api.pvp.net/api/lol/euw/v1.1/summoner/by-name/BestLuxEUW?api_key=[API-KEY]'
    end

    it 'should raise an error if the raise error status flag is enabled' do
      client = RiotApi::API.new :api_key => api_key, :region => 'euw', :raise_status_errors => true
      expect{ client.summoner.name 'fakemcfakename' }.to raise_error(Faraday::Error::ResourceNotFound, "the server responded with status 404")
    end
  end

  describe 'ssl settings' do
    it 'should by default enforce ssl' do
      subject.default_faraday.ssl.should == { :verify => true }
    end
  end

  describe '#summoner' do
    let(:summoner_name) { 'BestLuxEUW' }
    let(:summoner_id) { '44600324' }

    describe '#name' do
      let(:response) {
        subject.summoner.name summoner_name
      }

      it 'should return information from the summoner name' do
        response.id.should eql(44600324)
        response.name.should eql("Best Lux EUW")
        response.profile_icon_id.should eql(7)
        response.revision_date.should eql(1375116256000)
        response.revision_date_str.should eql('07/29/2013 04:44 PM UTC')
        response.summoner_level.should eql(6)
      end
    end

    describe '#id' do
      let(:response) {
        subject.summoner.id summoner_id
      }

      it 'should return information from the summoner id' do
        response.id.should eql(44600324)
        response.name.should eql("Best Lux EUW")
        response.profile_icon_id.should eql(7)
        response.revision_date.should eql(1375116256000)
        response.revision_date_str.should eql('07/29/2013 04:44 PM UTC')
        response.summoner_level.should eql(6)
      end
    end

    describe '#masteries' do
      let(:summoner_id) { '19531813' }

      let(:pages) { subject.summoner.masteries summoner_id }
      let(:page)  { pages.first }
      let(:talents) { page.talents }
      let(:talent)  { talents.first }

      it 'should return a list of mastery pages containing lists of talents' do
        page.class.should == RiotApi::Model::MasteryPage
        talent.class.should == RiotApi::Model::Talent
        talent.name.should_not be_nil
      end
    end

    describe '#names' do
      let(:froggen) { '19531813' }
      let(:response) {
        subject.summoner.names summoner_id, froggen
      }

      it "should return an array of summoners with name set" do
        response.class.should == Array
        response.count.should == 2
        response.first.class.should == RiotApi::Model::Summoner
        response.first.name.should == "Best Lux EUW"
      end
    end

    describe '#runes' do
      let(:summoner_id) { '19531813' }

      let(:pages) { subject.summoner.runes summoner_id }
      let(:page)  { pages.first }
      let(:slot)  { page.slots.first }
      let(:rune)  { slot.rune }

      it 'should return a list of rune pages containing lists of talents' do
        page.class.should == RiotApi::Model::RunePage
        slot.class.should == RiotApi::Model::RuneSlot
        rune.class.should == RiotApi::Model::Rune
        rune.id.should_not be_nil
      end
    end

  end

  describe '#stats' do
    let(:summoner_id) { '19531813' }

    # Ranked command requires user has played ranked
    describe '#ranked' do

      describe 'omitting season' do
        let(:champion_stats) { subject.stats.ranked summoner_id }
        let(:champion_stat)  { champion_stats.first }
        let(:stats) { champion_stat.stats }
        let(:stat)  { stats.first }

        it 'should return ranked information from the summoner id' do
          champion_stats.class.should == Array
          champion_stat.class.should == RiotApi::Model::ChampionStat
          stats.class.should == Array
          stat.class.should == RiotApi::Model::Statistic
          champion_stat.id.should == 111
        end
      end

      describe 'specifying season' do
        let(:champion_stats) { subject.stats.ranked summoner_id, :season => "SEASON3" }
        let(:champion_stat)  { champion_stats.first }
        let(:stats) { champion_stat.stats }
        let(:stat)  { stats.first }

        it 'should return ranked information from the summoner id for the specified season' do
          champion_stats.class.should == Array
          champion_stat.class.should == RiotApi::Model::ChampionStat
          stats.class.should == Array
          stat.class.should == RiotApi::Model::Statistic
          champion_stat.id.should == 111
        end
      end
    end

    describe '#summary' do

      describe 'omitting season' do
        let(:player_stat_summaries) { subject.stats.summary summoner_id }
        let(:player_stat_summary)  { player_stat_summaries.first }
        let(:aggregated_stats) { player_stat_summary.aggregated_stats }
        let(:aggregated_stat)  { aggregated_stats.first }

        it 'should return summary information from the summoner id' do
          player_stat_summaries.class.should == Array
          player_stat_summary.class.should == RiotApi::Model::PlayerStatSummary
          aggregated_stats.class.should == Array
          aggregated_stat.class.should == RiotApi::Model::Statistic
          player_stat_summary.losses.should == 0
        end
      end

      describe 'specifying season' do
        let(:player_stat_summaries) { subject.stats.summary summoner_id, :season => "SEASON3" }
        let(:player_stat_summary)  { player_stat_summaries.first }
        let(:aggregated_stats) { player_stat_summary.aggregated_stats }
        let(:aggregated_stat)  { aggregated_stats.first }

        it 'should return summary information from the summoner id for the specified season' do
          player_stat_summaries.class.should == Array
          player_stat_summary.class.should == RiotApi::Model::PlayerStatSummary
          aggregated_stats.class.should == Array
          aggregated_stat.class.should == RiotApi::Model::Statistic
          player_stat_summary.losses.should == 0
        end
      end
    end

  end

  describe '#champions' do
    let(:current_champion_count) { 116 }

    describe '#list' do
      let(:champions) {
        subject.champions.list
      }

      it 'should return a list of all champions' do
        champions.count.should be >= current_champion_count
        champions.first.respond_to?(:name).should be_true
      end
    end

    describe '#free' do
      let(:champions) {
        subject.champions.free
      }

      it 'should return a list of all free champions' do
        champions.should_not be_empty
        champions.count.should be < current_champion_count
        champions.first.respond_to?(:name).should be_true
        champions.first.free_to_play.should be_true
      end
    end

  end

  describe '#game' do
    let(:summoner_id) { '19531813' }

    # Ranked command requires user has played ranked
    describe '#recent' do
      let(:games) { subject.game.recent summoner_id }
      let(:game)  { games.first }

      it 'should return a list of recent games played' do
        game.class.should == RiotApi::Model::Game
        game.champion_id.should_not be_nil
        game.fellow_players.first.class.should == RiotApi::Model::Player
        game.statistics.first.class.should == RiotApi::Model::Statistic
      end
    end
  end

  describe '#league', :vcr do
    let(:summoner_id) { '19531813' }

    describe '#by_summoner' do
      let(:league) { subject.league.by_summoner summoner_id }

      it 'should return league object for summoner' do
        league.class.should == RiotApi::Model::League
        league.tier.should == 'CHALLENGER'
        league.entries.count.should > 0
        league.entries.first.class.should == RiotApi::Model::LeagueEntry
      end
    end
  end


  describe '#team', :vcr do
    let(:summoner_id) { '19531813' }

    describe '#by_summoner' do
      let(:teams) { subject.team.by_summoner summoner_id }
      let(:team)  { teams.first }

      let(:match_history) { team.match_history }
      let(:match) { match_history.first }

      let(:roster) { team.roster }
      let(:member_list) { roster.member_list }
      let(:member) { member_list.first }

      let(:team_stat_summary) { team.team_stat_summary }
      let(:team_stat_details) { team_stat_summary.team_stat_details }
      let(:team_stat_detail)  { team_stat_details.first }

      let(:team_id) { team.team_id }

      it 'should return team data for summoner' do
        teams.should_not be_empty
        team.class.should == RiotApi::Model::Team

        match.assists.should_not be_nil

        roster.owner_id.should_not be_nil
        member.player_id.should_not be_nil

        team_stat_summary.team_id.should_not be_nil
        team_stat_detail.wins.should_not be_nil
        team_stat_detail.team_id.should_not be_nil
      end
    end
  end

end
