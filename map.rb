require './tempest.rb'

class Map
  attr_accessor :name, :level, :tempest

  def self.get(name)
    return nil if LEVELS[name].nil?
    return Map.new(name, LEVELS[name])
  end

  def self.get_all
   LEVELS.map do |name, level|
     Map.new(name, level)
   end
  end

  def initialize(name, level)
    @name = name
    @level = level
    tempest_base, votes = $redis.zrevrangebyscore(base_redis_key, '+inf', 1, :limit => [0, 1],:withscores => true)[0]
    tempest_suffix = $redis.zrevrangebyscore(suffix_redis_key, '+inf', 1, :limit => [0, 1])[0]
    @tempest = Tempest.new(tempest_base, tempest_suffix, (votes || 0).round)
  end

  def base_redis_key
    "#{@name}_base_#{Time.now.utc.hour}"
  end

  def suffix_redis_key
    "#{@name}_suffix_#{Time.now.utc.hour}"
  end

  # Add a vote for the tempest being active on the given map
  # Increments the tempests counter in the maps SortedSet
  def report_tempest(tempest, voter, seconds_to_reset, skip_validation = false)
    unless skip_validation
      voter_key = "#{@name}::#{voter}"
      return if $redis.exists voter_key
      $redis.set voter_key, 1
      $redis.expire voter_key, seconds_to_reset
    end

    base_key = base_redis_key
    $redis.zincrby(base_key, 1, tempest.base_name)
    $redis.expire(base_key, 3600)

    suffix_key = suffix_redis_key
    $redis.zincrby(suffix_key, 1, tempest.suffix_name)
    $redis.expire(suffix_key, 3600)
  end

  LEVELS = {
    'crypt' => 68,
    'desert' => 68,
    'dunes' => 68,
    'dungeon' => 68,
    'grotto' => 68,
    'pit' => 68,
    'tropical_island' => 68,
    'aqueduct' => 69,
    'arcade' => 69,
    'cemetery' => 69,
    'channel' => 69,
    'mountain_ledge' => 69,
    'sewer' => 69,
    'thicket' => 69,
    'wharf' => 69,
    'ghetto' => 70,
    'mud_geyser' => 70,
    'museum' => 70,
    'quarry' => 70,
    'reef' => 70,
    'spider_lair' => 70,
    'vaal_pyramid' => 70,
    'arena' => 71,
    'overgrown_shrine' => 71,
    'promenade' => 71,
    'shore' => 71,
    'spider_forest' => 71,
    'tunnel' => 71,
    'bog' => 72,
    'coves' => 72,
    'graveyard' => 72,
    'pier' => 72,
    'underground_sea' => 72,
    'villa' => 72,
    'arachnid_nest' => 73,
    'catacomb' => 73,
    'colonnade' => 73,
    'dry_woods' => 73,
    'strand' => 73,
    'temple' => 73,
    'jungle_valley' => 74,
    'labyrinth' => 74,
    'mine' => 74,
    'torture_chamber' => 74,
    'waste_pool' => 74,
    'canyon' => 75,
    'cells' => 75,
    'dark_forest' => 75,
    'dry_peninsula' => 75,
    'orchard' => 75,
    'arid_lake' => 76,
    'gorge' => 76,
    'residence' => 76,
    'underground_river' => 76,
    'abyss' => 77,
    'bazaar' => 77,
    'necropolis' => 77,
    'plateau' => 77,
    'academy' => 78,
    'crematorium' => 78,
    'precinct' => 78,
    'springs' => 78,
    'arsenal' => 79,
    'overgrown_ruin' => 79,
    'shipyard' => 79,
    'village_ruin' => 79,
    'courtyard' => 80,
    'excavation' => 80,
    'wasteland' => 80,
    'waterways' => 80,
    'maze' => 81,
    'palace' => 81,
    'shrine' => 81,
    'vaal_temple' => 81,
    'colosseum' => 82,
    'core' => 82,
    'volcano' => 82
  }
end
