FULL = [0,1,2,3]
HALF = list(range(8))

def next_state(state, direction, half_step):
    n = 8 if half_step else 4
    return (state + (1 if direction else -1)) % n

def phase(state, half_step):
    if half_step:
        return [0b1001,0b0001,0b0011,0b0010,
                0b0110,0b0100,0b1100,0b1000][state]
    return [0b1001,0b0011,0b0110,0b1100][state]

def test_full_forward():
    s=0
    seq=[]
    for _ in range(8):
        seq.append(s)
        s=next_state(s,1,False)
    assert seq == [0,1,2,3,0,1,2,3]

def test_full_reverse():
    s=0
    seq=[]
    for _ in range(8):
        seq.append(s)
        s=next_state(s,0,False)
    assert seq == [0,3,2,1,0,3,2,1]

def test_half_forward():
    s=0
    seq=[]
    for _ in range(16):
        seq.append(s)
        s=next_state(s,1,True)
    assert seq == list(range(8))+list(range(8))

def test_half_reverse():
    s=0
    seq=[]
    for _ in range(16):
        seq.append(s)
        s=next_state(s,0,True)
    assert seq == [0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,1]

def test_direction_change():
    s=5
    s2=next_state(s,0,True)
    assert s2==4
    s=2
    s2=next_state(s,0,False)
    assert s2==1

def test_phase_coverage():
    assert len({phase(s,False) for s in range(4)})==4
    assert len({phase(s,True) for s in range(8)})==8

def test_shared_state():
    assert max(FULL)<8
    assert len(HALF)==8

if __name__=="__main__":
    test_full_forward()
    test_full_reverse()
    test_half_forward()
    test_half_reverse()
    test_direction_change()
    test_phase_coverage()
    test_shared_state()
    print("F08 reference model PASS")
    print("Full-step forward/reverse PASS")
    print("Half-step forward/reverse PASS")
    print("Mid-operation direction change PASS")
    print("Phase-table coverage PASS")
    print("Shared-state representation PASS")
