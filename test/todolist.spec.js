const assert = require('chai').should();
const {
    ensureContractAssertionError,
    getEos,
    snooze
} = require('./utils');
const {
    ERRORS
} = require('./constants');

describe('plus nums', () => {
    it('1 + 1 = 2  ', () => {
        let val = 1 + 1;
        val.should.be.equal(3);
    });
});