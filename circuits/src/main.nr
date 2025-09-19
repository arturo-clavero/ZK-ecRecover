use dep::ecrecover;
use dep::std;

fn main(
    pub_key_x: [u8; 32],
    pub_key_y: [u8; 32],
    signature: [u8; 64],
    hashed_message: pub [u8; 32],
) {
    verifySignature(pub_key_x, pub_key_y, signature, hashed_message);
}

fn verifySignature(
    pub_x: [u8; 32],
    pub_y: [u8; 32],
    signature: [u8; 64],
    hashed_message: [u8; 32],
) {
    let address = ecrecover::ecrecover(pub_x, pub_y, signature, hashed_message);
    std::println(address);
    assert(address != 0);
}

// #[test]
// fn test_main() {
//     main(1, 2);

// }
