%lang starknet
from starkware.cairo.common.alloc import alloc

//****************************************************************************
// REALMS SCORE - In Progress Representation of Realms Cimbalom Score
// TO DO - Represent Melodies as scale degress with relative octaves specified
//****************************************************************************

// Notes consist of the following data: Duration, KeyNum, Tick (aka location in time), Velocity (Intensity) 

@view
func realms_note_generator{range_check_ptr}(
    site_data_len: felt,
    site_data: felt*,
    out_data_len: felt,
    out_data: felt*,
    arr_idx: felt,
    pitchcollection_len: felt,
    pitchcollection: felt*,
    harmony_table_len: felt,
    harmony_table: felt*,
    randarr_len: felt,
    randarr: felt*,
    randinc: felt,
    drawer_data: HarmonizerInputArgs,
    numharms: felt,
) -> (out_data_len: felt, out_data: felt*) {
    alloc_locals;

    if (numharms == 0) {
        return (out_data_len=out_data_len, out_data=out_data);
    }

    let (numvoicings, _) = unsigned_div_rem(harmony_table_len - 1, harmony_table[0]);
    let (_, harmony_table_index) = unsigned_div_rem(randinc, numvoicings);

    // let (_, harmony_table_index2) = unsigned_div_rem(randinc, randarr_len)

    let rand_idx = randarr[harmony_table_index];

    if (drawer_data.inversion_val == 0) {
        let (newnote) = modal_transposition(
            site_data[arr_idx + 1],
            harmony_table[(rand_idx * harmony_table[0]) + numharms],
            drawer_data.tonic_idx,
            pitchcollection_len,
            pitchcollection,
        );
    } else {
        let (newnote) = modal_transposition_descend(
            site_data[arr_idx + 1],
            harmony_table[(rand_idx * harmony_table[0]) + numharms],
            drawer_data.tonic_idx,
            pitchcollection_len,
            pitchcollection,
        );
    }

    let inc_add = 4;

    let (new_duration, _) = unsigned_div_rem(site_data[arr_idx], drawer_data.num_divisions);

    // Compute Note Attributes

    assert out_data[out_data_len + 0] = new_duration;  // duration
    assert out_data[out_data_len + 1] = newnote;  // new note
    assert out_data[out_data_len + 2] = site_data[arr_idx + 2];  // tick
    assert out_data[out_data_len + 3] = site_data[arr_idx + 3];  // velocity

    let (out_data_len, out_data) = realms_note_generator(
        site_data_len=site_data_len,
        site_data=site_data,
        out_data_len=out_data_len + inc_add,
        out_data=out_data,
        arr_idx=arr_idx,
        pitchcollection_len=pitchcollection_len,
        pitchcollection=pitchcollection,
        harmony_table_len=harmony_table_len,
        harmony_table=harmony_table,
        randarr_len=randarr_len,
        randarr=randarr,
        randinc=randinc,
        drawer_data=drawer_data,
        numharms=numharms - 1,
    );

    return (out_data_len=out_data_len, out_data=out_data);
}


@view
func realms_voicing_table{range_check_ptr}() -> (table_len: felt, table: felt*) {
    alloc_locals;

    let (local table) = alloc();

    // assert first element as the number of harmonies in a voicing above a note
    // Four part including transposed note

    assert [table + 0] = 4;

    assert [table + 1] = 24;
    assert [table + 2] = 28;
    assert [table + 3] = 33;
    assert [table + 4] = 36;

    assert [table + 5] = 26;
    assert [table + 6] = 28;
    assert [table + 7] = 31;
    assert [table + 8] = 35;

    assert [table + 9] = 24;
    assert [table + 10] = 28;
    assert [table + 11] = 29;
    assert [table + 12] = 33;

    assert [table + 13] = 26;
    assert [table + 14] = 31;
    assert [table + 15] = 33;
    assert [table + 16] = 35;

    return (table_len=17, table=table);
}

@view
func realms_bassline_table{range_check_ptr}() -> (table_len: felt, table: felt*) {
    alloc_locals;

    let (local table) = alloc();

    // assert first element as the number of harmonies in a voicing above a note
    // Four part including transposed note

    assert [table + 0] = 8;

    assert [table + 1] = 45;
    assert [table + 2] = 40;
    assert [table + 3] = 41;
    assert [table + 4] = 40;

    assert [table + 5] = 45;
    assert [table + 6] = 43;
    assert [table + 7] = 41;
    assert [table + 8] = 43;

    return (table_len=9, table=table);
}

