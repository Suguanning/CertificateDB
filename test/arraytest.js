const Test = artifacts.require("Test");
contract('certificate',(accounts)=>{
    it('test ',async ()=>{
        const instance = await Test.deployed();
        await instance.test();

    })
    it('test 2',async ()=>{
        const instance = await Test.deployed();
        await instance.test2();

    })
})