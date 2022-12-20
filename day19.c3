module day19;
import std::io;
import std::math;
import std::map;
import std::array::list;

define BlueprintList = List<Blueprint>;

const usz ORE = 0;
const usz CLAY = 1;
const usz OBSIDIAN = 2;
const usz GEODE = 3;

BlueprintList blueprints;
struct Blueprint
{
	int[<4>] ore_cost;
	int[<4>] clay_cost;
	int[<4>] obsidian_cost;
	int[<4>] geode_cost;
	int[<4>] max_cost;
}

struct GameState
{
	int[<4>] goods;
	int[<4>] robots;
	bool[<4>] block_robot;
	bool[<4>] temp_block;
}

fn void load_blueprints()
{
	File f;
	f.open("blueprint.txt", "rb")!!;
	blueprints.init();
	defer catch(f.close());
	while (!f.eof())
	{
		@pool()
		{
			Blueprint print;
			char[] line = f.tgetline();
			char[][] split = str::tsplit(line, "Each ore robot costs ");
			split = str::tsplit(split[1], " ore. Each clay robot costs ");
			print.ore_cost = { [ORE] = str::to_int(split[0])!! };
			split = str::tsplit(split[1], " ore. Each obsidian robot costs ");
			print.clay_cost = { [ORE] = str::to_int(split[0])!! };
			split = str::tsplit(split[1], " clay. Each geode robot costs ");
			char[][] split2 = str::tsplit(split[0], " ore and ");
			print.obsidian_cost = {
				[ORE] = str::to_int(split2[0])!!,
				[CLAY] = str::to_int(split2[1])!!
 			};
			split2 = str::tsplit(split[1], " ore and ");
			print.geode_cost = {
				[ORE] = str::to_int(split2[0])!!,
				[OBSIDIAN] = str::to_int(split2[1][..^11])!!
 			};
 			print.max_cost = math::max(math::max(math::max(print.geode_cost, print.obsidian_cost), print.clay_cost), print.ore_cost);
			blueprints.append(print);
		};
	}
}

fn int do_next_day(int day, GameState state, Blueprint* b)
{
	if (day == 0) return state.goods[GEODE];
	if (day == 1) return state.goods[GEODE] + state.robots[GEODE];
	int best_result = -1;
	bool[<4>] temp_block = { };
	if (state.goods.comp_ge(b.geode_cost).and())
    {
		return {|
			GameState copy_state = state;
			copy_state.temp_block = {};
			copy_state.goods += state.robots;
			copy_state.goods -= b.geode_cost;
			copy_state.robots[GEODE]++;
			return do_next_day(day - 1, copy_state, b);
		|};
	}
	if (day == 2) return state.goods[GEODE] + state.robots[GEODE] * 2;

	bool temp_block_obsidian = false;
	if EXIT: (!state.temp_block[OBSIDIAN] && !state.block_robot[OBSIDIAN] && state.goods.comp_ge(b.obsidian_cost).and())
	{
	    if (state.robots[OBSIDIAN] * day + state.goods[OBSIDIAN] >= b.max_cost[OBSIDIAN] * day)
		{
			state.block_robot[OBSIDIAN] = true;
			break EXIT;
		}
		int result = {|
			GameState copy_state = state;
			copy_state.temp_block = {  };
			copy_state.goods += state.robots;
			copy_state.goods -= b.obsidian_cost;
			copy_state.robots[OBSIDIAN]++;
			return do_next_day(day - 1, copy_state, b);
		|};
		if (result > best_result) best_result = result;
		temp_block[OBSIDIAN] = true;
	}

	if EXIT: (!state.temp_block[CLAY] && !state.block_robot[CLAY] && state.goods.comp_ge(b.clay_cost).and())
	{
	    if (state.robots[CLAY] * day + state.goods[CLAY] >= b.max_cost[CLAY] * day)
		{
			state.block_robot[CLAY] = true;
			break EXIT;
		}
		int result = {|
			GameState copy_state = state;
			copy_state.temp_block = { };
			copy_state.goods += state.robots;
			copy_state.goods -= b.clay_cost;
			copy_state.robots[CLAY]++;
			return do_next_day(day - 1, copy_state, b);
		|};
		if (result > best_result) best_result = result;
		temp_block[CLAY] = true;
	}
	if EXIT: (!state.block_robot[ORE] && state.goods.comp_ge(b.ore_cost).and())
	{
	    if (state.robots[ORE] * day + state.goods[ORE] >= b.max_cost[ORE] * day)
		{
			state.block_robot[ORE] = true;
			break EXIT;
		}
		int result = {|
			GameState copy_state = state;
			copy_state.temp_block = { };
			copy_state.goods += state.robots;
			copy_state.goods -= b.ore_cost;
			copy_state.robots[ORE]++;
			return do_next_day(day - 1, copy_state, b);
		|};
		temp_block[ORE] = true;
		if (result > best_result) best_result = result;
	}
	state.goods += state.robots;
	state.temp_block = state.temp_block | temp_block;
	int result = do_next_day(day - 1, state, b);
	return best_result > result ? best_result : result;
}

fn void part1()
{
	int quality_sum = 0;
	foreach (int i, Blueprint b : blueprints)
	{
		GameState state = {};
		state.robots[ORE] = 1;
		int geodes = do_next_day(24, state, &b);
		quality_sum += (i + 1) * geodes;
	}
	io::printfln("Quality sum: %d", quality_sum);
}

fn void part2()
{
	long quality = 1;
	foreach (int i, Blueprint b : blueprints)
	{
		if (i > 2) break;
		GameState state = {};
		state.robots[ORE] = 1;
		long geodes = do_next_day(32, state, &b);
		quality *= geodes;
	}
	io::printfln("Quality product: %d", quality);
}

fn void main()
{
	load_blueprints();
	part1();
	part2();
}