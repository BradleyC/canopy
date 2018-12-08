pragma solidity ^0.4.24;

contract Canopy {

    /*** DATA HANDLING ***/
    struct Post {
        address posterAddress;
        string title;
        string url;
        string content;
        uint timePosted;
        uint stake;
        uint256 voteTokens;
        uint256 score;
        uint valuePositive;
        uint valueNegative;
        uint256 voterTally;
        bool active;
    }

    address public maintainersAddress;
    address public gameMasterAddress;
    address public newContractAddress;

    constructor () public {
        // This is an empty constructor.
    }

    /*** EVENTS ***/
    event NewPost(
        uint256 indexed postId,
        address posterAddress,
        string title,
        string url,
        string content,
        uint indexed timePosted,
        uint stake,
        uint256 score,
        bool active
    );
    event ContractUpgrade(address indexed newContract);

    /*** STORAGE ***/
    Post[] public posts;
    address[] internal participants; // used for rolling jackpot

    mapping (uint256 => address) public postIdToOwner;
    mapping (uint256 => address[]) public postIdToVoters;
    mapping (address => uint256) public userPostCount;

    /// @dev canopy is currently in Alpha. Expect upgrades; currently following CK pattern for upgrade.
    /// @param _v2Address new address
    
    function setNewAddress(address _v2Address) external onlyGameMaster {
        newContractAddress = _v2Address;
        emit ContractUpgrade(_v2Address);
    }
    
    /*** CORE ***/
    // @dev function to create a new post
    function createPost(string title, string url, string content)
        // TODO: make sure "stake" transfer is executed properly
        public
        payable
        returns (
            uint256,
            uint256
        ){
        // below: intentionally ignoring warning on "now"; time is non-critical
        uint timePosted = now;
        address poster = msg.sender;
        // below: start score = (1 up - 0 down) * (1 voter / 1 second since post)
        uint256 score = 1;
        Post memory post = Post({
            posterAddress: poster,
            title: title,
            url: url,
            content: content,
            timePosted: timePosted,
            stake: msg.value,
            voteTokens: 0,
            score: score,
            valuePositive: 0,
            valueNegative: 0,
            voterTally: 0,
            active: true
        });

        uint256 newPostId = posts.push(post) - 1;
        userPostCount[poster]++;
        participants.push(msg.sender);
        emit NewPost(
            numPosts,
            poster,
            title,
            url,
            content,
            timePosted,
            msg.value,
            score,
            true
        );
        return (numPosts, score);
    }

    function getPost(uint256 _id)
        public
        view
        returns (
            address posterAddress,
            string title,
            string url,
            string content,
            uint timePosted,
            uint stake,
            uint256 score,
            uint valuePositive,
            uint valueNegative,
            uint256 voterTally,
            bool active
        ) {
        Post memory p = posts[_id];
        return(
            p.posterAddress,
            p.title,
            p.url,
            p.content,
            p.timePosted,
            p.stake,
            p.score,
            p.valuePositive,
            p.valueNegative,
            p.voterTally,
            p.active
        );
    }

    // @dev pass in vote params. return the vote weight instantly, re-rank posts
    function vote(uint256 _postId, bool isPositive) public payable returns (uint256) {
        Post memory c = posts[_postId];
        if (isPositive) {
            c.valuePositive = c.valuePositive + msg.value;
        } else {
            c.valueNegative = c.valueNegative + msg.value;
        }
        // stake is not modified here. total payout is sort of equal to
        // stake + valuePositive - valueNegative
        c.voterTally++;
        postIdToVoters[_postId].push(msg.sender);
        c.score = scorePost(_postId);
        participants.push(msg.sender);
        updateActiveScores();
        return c.score;
    }

    function updateActiveScores() private {
        for (uint i = 0; i < posts.length; i++) {
            Post memory c = posts[i];
            // if a post is a month old, pay it out and deactivate
            if (c.active == true) {
                if ((now - c.timePosted) > 30 days) {
                    cashOut(i);
                } else {
                    scorePost(i);
                }
            }
        }
    }

    function scorePost(uint256 _postId) private returns (uint256) {
        Post memory p = posts[_postId];
        // multiply by 100000 to ensure an integer
        uint256 uproot = sqrt((p.valuePositive) * 100000);
        uint256 downroot = sqrt((p.valueNegative) * 100000);
        uint256 totalVoters = p.voterTally;
        uint256 rootTimeSincePost = sqrt(now - p.timePosted);
        uint256 _score = (uproot / downroot) * (totalVoters / rootTimeSincePost);
        posts[_postId].score = _score;
        return _score;
    }

    // below method is borrowed from https://github.com/ethereum/dapp-bin/pull/50/files
    function sqrt(uint256 x) internal pure returns (uint256 y) {
        if (x == 0) return 0;
        else if (x <= 3) return 1;
        uint z = (x + 1) / 2;
        y = x;
        while (z < y)
        {
            y = z;
            z = (x / z + z) / 2;
        }
    }

    // @dev read from mapping - show 100 of the most recent
    function getMostRecentPostId() public view returns (uint256) {
        //since IDs are sequential, length of array = most recent post id
        return posts.length - 1;
    }

    // @dev read from mapping
    function getScoreById(uint _postId) public view returns (uint256) {
        return posts[_postId].score;
    }

    // @dev user can choose when to cash out, make sure to check address
    function cashOut(uint _postId) public payable onlyPoster(_postId) {
        uint256 poolValue = address(this).balance;
        require(poolValue >= 0.01 ether, "pool value is too small");

        Post memory p = posts[_postId];
        uint totalValue = p.valuePositive + p.valueNegative;
        uint totalRatio = 100 * sqrt(p.valuePositive) / sqrt(p.valueNegative);
        uint basePaymentToPoster = p.stake * (100 * sqrt(p.valuePositive) / sqrt(totalValue)) / 100 + p.valuePositive;

        // calculate bonus
        require(totalRatio < 75, "your post failed to meet the quality bar");
        uint bonusRatio;
        if (totalRatio < 2) {
            bonusRatio = totalRatio;
        } else {
            bonusRatio = 2;
        }

        uint bonusPayout = p.stake * bonusRatio;

        // make sure that bonus isn't too much of pool
        uint totalBonus;
        if (bonusPayout < (poolValue / 2)) {
            totalBonus = bonusPayout;
        } else {
            totalBonus = (poolValue / 2);
        }

        uint totalPayout = basePaymentToPoster + totalBonus;
        msg.sender.transfer(totalPayout);
        posts[_postId].active = false;
        posts[_postId].score = 0;
    }

    function jackpot() public payable onlyGameMaster {
        require (address(this).balance > 25 ether, "can't make it rain if there ain't no cloud");
        uint numerator = address(this).balance;
        uint denominator = participants.length;
        uint jackpotBalance = (.70 * address(this).balance);
        uint maintainerPay = (.10 * address(this).balance);
        uint perPlayer = jackpot / (numerator / denominator);
        for (i = 0; i < participants.length; i++) {
            participants[i].send(perPlayer);
        }
        maintainersPot(maintainerPay);
    }

    function maintainersPot(uint amount) internal payable onlyMaintainers {
        require(maintainersAddress != 0, "no burning");
        mantainersAddress.send(amount);
    }

    // @dev BONUS - get post with highest tally of votes
    // @dev BONUS - get user's total voter tally

    /*** PERMISSIONS ***/
    // @dev check against addresses
    modifier onlyPoster(uint _postId) {
        require(msg.sender == posts[_postId].posterAddress, "Only the poster can use this function");
        _;
    }

    modifier onlyMaintainers() {
        require(msg.sender == maintainersAddress, "Only the maintainer is allowed this action");
        _;
    }

    modifier onlyGameMaster() {
        require(msg.sender == gameMasterAddress, "Only the Game Master is able to change the rules");
        _;
    }

}
