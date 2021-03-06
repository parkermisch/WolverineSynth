function sig = all_track_to_sig(cumul, tm)
    sig = 0;
    for track = 1:length(cumul)
        cur_sig = [];
        for note = cumul{track}
            cur_sig = [cur_sig write_note(note, tm)];
        end
        if length(cur_sig) < length(sig)
            cur_sig(length(sig)) = 0;
        elseif length(cur_sig) > length(sig)
            sig(length(cur_sig)) = 0;
        end
        sig = sig + cur_sig;
    end
end
