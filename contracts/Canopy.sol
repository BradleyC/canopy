pragma solidity ^0.4.24;

contract Canopy {

    /*** DATA HANDLING ***/
    struct Post {
        address posterAddress;
        string title;
        string url;
        uint256 timePosted;
        uint256 stake;
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

    /*** STORAGE ***/
    Post[] posts;
    address[] private participants; // used for rolling jackpot
    uint256[40] public top40PostIds;

    mapping (uint256 => address) public postIdToOwner;
    mapping (uint256 => uint256) public postIdToTime;
    mapping (uint256 => uint256) public postIdToScore;
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
        uint256 _timePosted = now;
        address _poster = msg.sender;
        // below: start score = (1 up - 0 down) * (1 voter / 1 second since post)
        _score = 1;
        Post memory _post = Post({
            posterAddress: _poster,
            title: title,
            url: url,
            timePosted: _timePosted,
            stake: stake,
            score: _score,
            // regardless of stake value, self votes always count as one vote
            valuePositive: 1,
            valueNegative: 0,
            voterTally: 1,
            active: true
        });

        uint256 newPostId = posts.push(_post) - 1;
        postIdToOwner[newPostId] = _poster;
        postIdToTime[newPostId] = _timePosted;
        // below: new post is initiated with score of 1
        postIdToScore[newPostId]++;
        userToTotalScore[_poster]++;
        userPostCount[_poster]++;
        userToVoterTally[_poster]++;
        emit NewPost(
            newPostId, 
            _poster, 
            title, 
            url, 
            _timePosted, 
            stake, 
            _score, 
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
    function getRankedPosts() internal pure {
        getPost();
    }

    // @dev pass in vote params. return the vote weight instantly, re-rank posts
    function vote() external returns (uint256) {
        // voting logics
        getScoreById();
        rankPosts();
        // update mappings
        return score;
    }

    // @dev process to rank posts
    // evaluate score and if applicable, add to post top 40
    function rankPosts() internal {}

    // ranking
    // iterate over vote totals in list starting with floor = 0
    // create inner top 10 array biggest -> smallest
    // if vote total > floor, loop through inner array.
    // if vote total < current object in inner array, insert and pop last element
    
    function rankPosts() internal {}

    // @dev read from mapping
    function getPostsByTime() external {}

    // @dev read from mapping
    function getScoreById() internal {}

    // @dev user can choose when to cash out, make sure to check address
    function cashOut() external payable onlyPoster {}

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
