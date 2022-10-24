import BTreeMap "../../src/btreemap";
//import VecMemory "../../src/memory/vecMemory";
import VecMemory "../../src/memory/initializableVecMemory";
import Types "../../src/types";

import Blob "mo:base/Blob";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";

import Iter "mo:base/Iter";
import Result "mo:base/Result";

actor {
  type Result<Ok, Err> = Result.Result<Ok, Err>;

  stable var stableMemoryBuffer: [Nat8] = [];

  let textConverter = {
    fromBytes = func(bytes: [Nat8]): Text {
      let maybeText: ?Text = from_candid(Blob.fromArray(bytes));
      switch(maybeText) {
        case null { Debug.trap("") };
        case (?text) { 
          Debug.print("fromBytes [Nat8] to Text = " # debug_show(text));
          text 
        };
      }
    };
    toBytes = func(text: Text): [Nat8] {
      let res = Blob.toArray(to_candid(text));
      Debug.print("toBytes Text to [Nat8] = " # debug_show(res));
      res
    };
  };

  let natConverter = {
    fromBytes = func(bytes: [Nat8]): Nat {
      let maybeNat: ?Nat = from_candid(Blob.fromArray(bytes));
      switch(maybeNat) {
        case null { Debug.trap("") };
        case (?nat) { 
          Debug.print("fromBytes [Nat8] to Nat = " # debug_show(nat));
          nat 
        };
      }
    };
    toBytes = func(nat: Nat): [Nat8] {
      let res = Blob.toArray(to_candid(nat));
      Debug.print("toBytes Nat to [Nat8] = " # debug_show(res));
      res
    };
  };

  var mem = VecMemory.VecMemory(null);
  var bt = BTreeMap.init<Text, Nat>(
    mem,
    20,
    8,
    textConverter,
    natConverter
  );

  public func insert(key: Text, value: Nat): async Result<?Nat, Types.InsertError> {
    bt.insert(key, value);
  };

  public func get(key: Text): async ?Nat {
    bt.get("hello");
  };

  public func entries(): async [(Text, Nat)] {
    Iter.toArray<(Text, Nat)>(bt.iter());
  };

  public func helloWorld(): async Text {
    "Hello World! Upgrading! And again"
  };


  system func preupgrade() {
    stableMemoryBuffer := mem.buffer_.toArray();
  };

  system func postupgrade() {
    mem := VecMemory.VecMemory(
      ?Buffer.fromArray<Nat8>(stableMemoryBuffer)
    );
    bt := BTreeMap.init<Text, Nat>(
      mem,
      20,
      8,
      textConverter,
      natConverter
    );
  };

}