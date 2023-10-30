module day20;
import std::io;
import std::math;
import std::collections::map;
import std::collections::list;

def LongList = List(<long>);

fn void load_crypto(LongList* list, LongList* pos, long key)
{
	File f = file::open("crypto.txt", "rb")!!;
	defer (void)f.close();
	while (!f.eof())
	{
		@pool()
		{
			String line = io::treadline(&f)!!;
			list.append(key * line.to_long()!!);
			pos.append((int)pos.len());
		};
	}
}

fn long value_at_pos(LongList list, LongList pos, long i) @inline
{
	foreach (long j, loc : pos)
	{
		if (loc == i) return list.get(j);
	}
	assert(false);
}

macro print_order(LongList pos)
{
   	foreach (x : pos)
   	{
		io::printf("%s ", x);
	}
    io::printn();
}

fn void print_list(LongList list, LongList pos)
{
	print_order(pos);
	long len = list.len();
	for (long i = 0; i < len; i++)
	{
       	io::printf("%s ", value_at_pos(list, pos, i));
	}
    io::printn();
}


fn void solve(int key, int mixes)
{
	LongList list;
	LongList pos;
	list.init();
	pos.init();
	defer pos.free();
	defer list.free();
	load_crypto(&list, &pos, key);
	long len = list.len();
	long mod = len - 1;
	for (int mix = 0; mix < mixes; mix++)
	{
		foreach (int i, long loc : pos)
    	{
    		long value = list.get(i);
    		if (value == 0) continue;
    		long new_position = (value + loc) % mod;
			if (new_position < 1) new_position += mod;
			long index = 0;
			// "Remove"
			foreach (j, &loc_ref : pos)
    		{
    			long l = *loc_ref;
    			if (l == loc)
    			{
    			    *loc_ref = new_position;
    			    index = j;
    			    continue;
    			}
    			if (l > loc) (*loc_ref)--;
    		}
    		// "Insert"
			foreach (j, &loc_ref : pos)
    		{
    			long l = *loc_ref;
    		    if (j == index) continue;
    			if (l >= new_position) (*loc_ref)++;
    		}
    	}
	}
	long zero_place = 0;
	foreach (long i, val : list)
	{
		if (val == 0)
		{
			zero_place = i;
			break;
		}
	}
	long zero_loc = pos.get(zero_place);
	long x1000 = value_at_pos(list, pos, (zero_loc + 1000) % len);
	long x2000 = value_at_pos(list, pos, (zero_loc + 2000) % len);
	long x3000 = value_at_pos(list, pos, (zero_loc + 3000) % len);
	io::printfn("Total: %d + %d + %d = %d", x1000, x2000, x3000, x1000 + x2000 + x3000);
}

fn void main()
{
	solve(1, 1);
	solve(811589153, 10);
}