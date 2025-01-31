import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Ensure node registration works",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get("deployer")!;
    const wallet1 = accounts.get("wallet_1")!;

    let block = chain.mineBlock([
      Tx.contractCall("zenith-node", "register-node", 
        [types.uint(1000)], wallet1.address)
    ]);
    
    assertEquals(block.receipts.length, 1);
    assertEquals(block.height, 2);
    
    block.receipts[0].result
      .expectOk()
      .expectBool(true);
  },
});

Clarinet.test({
  name: "Ensure duplicate registration fails",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet1 = accounts.get("wallet_1")!;

    let block = chain.mineBlock([
      Tx.contractCall("zenith-node", "register-node", 
        [types.uint(1000)], wallet1.address),
      Tx.contractCall("zenith-node", "register-node", 
        [types.uint(1000)], wallet1.address)
    ]);

    assertEquals(block.receipts.length, 2);
    block.receipts[1].result
      .expectErr()
      .expectUint(101);
  },
});

Clarinet.test({
  name: "Test status updates",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet1 = accounts.get("wallet_1")!;

    let block = chain.mineBlock([
      Tx.contractCall("zenith-node", "register-node", 
        [types.uint(1000)], wallet1.address),
      Tx.contractCall("zenith-node", "update-status",
        [types.ascii("active")], wallet1.address)
    ]);

    assertEquals(block.receipts.length, 2);
    block.receipts[1].result
      .expectOk()
      .expectBool(true);
  },
});
