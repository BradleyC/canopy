pragma solidity ^0.4.24;

contract Canopy {

    /*** DATA HANDLING ***/
    struct Post {
        address posterAddress;
        string title;
        string url;
        uint256 timePosted;
        uint256 stake;
        uint256 voteTokens;
        uint256 score;
        uint256 valuePositive;
        uint256 valueNegative;
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
        uint256 indexed timePosted, 
        uint256 stake,
        uint256 score,
        bool active
    );
    // TODO: event NewVote(uint256 indexed postId, )
    event ContractUpgrade(address indexed newContract);

    /*** STORAGE ***/
    Post[] posts;
    address[] private participants; // used for rolling jackpot
    uint256[40] public top40PostIds;
    // below: uint256 to make sure we can fully support an enormous pool. 
    uint256 public poolValue = address(this).balance;

    mapping (uint256 => address) public postIdToOwner;
    mapping (uint256 => uint256) public postIdToTime;
    mapping (uint256 => uint256) public postIdToScore;
    mapping (uint256 => uint256) public postIdToVoteTokens;    
    mapping (uint256 => address[]) public postIdToVoters;
    mapping (address => uint256) public userPostCount;
    mapping (address => uint256) public userToTotalScore;
    mapping (address => uint256) public userToVoterTally;

    /// @dev canopy is currently in Alpha. Expect upgrades; currently following CK pattern for upgrade.
    /// @param _v2Address new address
    function setNewAddress(address _v2Address) external onlyGameMaster {
        newContractAddress = _v2Address;
        emit ContractUpgrade(_v2Address);
    }

    /*** CORE ***/
    // @dev function to create a new post
    function createPost(string title, string url, uint256 stake)
        // TODO: make sure "stake" transfer is executed properly  
        external
        returns (
            uint256,
            uint256
        ){
        // below: intentionally ignoring warning; time is non-critical
        uint256 timePosted = now;
        address poster = msg.sender;
        // below: start score = (1 up - 0 down) * (1 voter / 1 second since post)
        uint256 score = 1;
        Post memory post = Post({
            posterAddress: poster,
            title: title,
            url: url,
            timePosted: timePosted,
            stake: stake,
            voteTokens: 0,
            score: score,
            // regardless of stake value, self votes always count as one vote
            valuePositive: 1,
            valueNegative: 0,
            voterTally: 1,
            active: true
        });

        uint256 newPostId = posts.push(post) - 1;
        postIdToOwner[newPostId] = poster;
        postIdToTime[newPostId] = timePosted;
        postIdToVoteTokens[newPostId] = 0;
        // below: new post is initiated with score of 1
        postIdToScore[newPostId]++;
        userToTotalScore[poster]++;
        userPostCount[poster]++;
        userToVoterTally[poster]++;
        emit NewPost(
            newPostId, 
            poster, 
            title, 
            url, 
            timePosted, 
            stake, 
            score, 
            true
        );
        return (newPostId, score);
    }

    function getPost(uint256 _id) 
        internal
        view
        returns (
            address posterAddress,
            string title,
            string url,
            uint256 timePosted,
            uint256 stake,
            uint256 score,
            uint256 valuePositive,
            uint256 valueNegative,
            uint256 voterTally,
            bool active
        ) {
        Post memory p = posts[_id];
        return(
            p.posterAddress, 
            p.title, 
            p.url, 
            p.timePosted, 
            p.stake,
            p.score,
            p.valuePositive,
            p.valueNegative,
            p.voterTally,
            p.active
        );
    }

    // @dev fetch the list of ranked posts
    function getRankedPosts() internal view returns (uint256[]) {
        return top40PostIds;
    }

    // @dev pass in vote params. return the vote weight instantly, re-rank posts
    function vote() external returns (uint256) {
        // voting logics
        getScoreById();
        scorePost();
        // if score is greater than lowest in top 40
        rankPosts();
        // update mappings
        return score;
    }

    // @dev process to rank posts
    // evaluate score and if applicable, add to post top 40
    function rankPosts(uint256 _postId, uint256 _score) internal {
        // we're only entering this loop if we know that we have a score that displaces a high ranking score
        // update all scores
        for (uint i = 0; i < 40; i++) {
            uint currentId = top40PostIds[i];
            Post memory c = posts[currentId];
            if (( now - c.timePosted) > 2592000) {
                c.active = false;
                c.score = 0;
                cashOut(currentId);
            }
            // below is a lazy way to move inactive posts to the bottom of the top 40. 
            // it may take a view votes to force them out entirely.
            else if (c.active = false) {
                c.score = 0;
            }
            else scorePost(currentId);
        }
        // SORT


        // score floor
        // for p in posts
        // evaluate if score > floor
        // force pay out stale posts
        // merge sort?
        // ranking
        // iterate over vote totals in list starting with floor = 0
        // create inner top 40 array biggest -> smallest
        // if vote total > floor, loop through inner array.
        // if vote total < current object in inner array, insert and pop last element
    }

    function scorePost(uint256 _postId) internal returns (uint256) {
        Post memory p = posts[_postId];
        uint256 uproot = sqrt(p.valuePositive);
        uint256 downroot = sqrt(p.valueNegative);
        uint256 totalVoters = p.voterTally;
        uint256 rootTimeSincePost = sqrt(now - p.timePosted); 
        uint256 _score = (uproot / downroot)(totalVoters / rootTimeSincePost);
        posts[_postId].score = _score;
        return _score;
    }

    // below method is borrowed from https://github.com/ethereum/dapp-bin/pull/50/files
    function sqrt(uint256 x) internal returns (uint256 y) {
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

    // @dev read from mapping
    function getPostsByTime() external {}

    // @dev read from mapping
    function getScoreById() internal {}

    // @dev user can choose when to cash out, make sure to check address
    function cashOut(_postId) external payable onlyPoster {
        return;
    }

    // @dev BONUS - get post with highest tally of votes
    // @dev BONUS - get user's total score
    // @dev BONUS - get user's total voter tally

    /*** PERMISSIONS ***/
    // @dev check against addresses 
    modifier onlyPoster() {
        _;
    }

    modifier onlyMaintainers() {
        // line 19
        _;
    }

    modifier onlyGameMaster() {
        // line 20
        _;
    }
}
