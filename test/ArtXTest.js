const { expect } = require("chai");

const uri = "https://artx.io/"

describe("ArtX contract", function () {
  let ArtX;
  let artX;
  let addr1;
  let addr2;
  let addrs;

  before(async function () {
    ArtX = await ethers.getContractFactory("ArtX");
    [addr1, addr2, ...addrs] = await ethers.getSigners();

    artX = await ArtX.deploy();
  });

  describe("Mint", function () {
    it("Should mint a token for addr1", async function () {
        await artX.connect(addr1).mint(uri + "1")

        expect(await artX.ownerOf(1)).to.equal(addr1.address)
    });

    it("Should mint a token for addr2", async function () {
      await artX.connect(addr2).mint(uri + "2")

      expect(await artX.ownerOf(2)).to.equal(addr2.address)
    });
  });

  describe("Swap", function() {
      it("Should list token 1", async function() {
          await artX.connect(addr1).makeSwap(1, 2)

          expect(await artX.isInSwap(1)).to.be.true
      })

      it("Should swap token 1 and 2", async function() {
          await artX.connect(addr2).takeSwap(1, 2)

          expect(await artX.isInSwap(1)).to.be.false
          expect(await artX.ownerOf(1)).to.equal(addr2.address)
          expect(await artX.ownerOf(2)).to.equal(addr1.address)
      })
  })

  describe("Close", function() {
      it("Should list token 1", async function () {
        await artX.connect(addr2).makeSwap(1, 2);

        expect(await artX.isInSwap(1)).to.be.true;
      });

      it("Should close swap", async function () {
        await artX.connect(addr2).closeSwap(1);

        expect(await artX.isInSwap(1)).to.be.false;  // not in swap
        expect(await artX.ownerOf(1)).to.equal(addr2.address);  // not swapped
        expect(await artX.ownerOf(2)).to.equal(addr1.address);
      });
  })
});
