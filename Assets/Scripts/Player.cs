using UnityEngine;

public enum Direction
{
    Left,
    Right
}

public class Player : MonoBehaviour
{
    public float horizontalSpeed = 10;

    public float jumpForce = 20;

    public float playerSightRadius = 5.0f;

    public float animationSpeed = 1.0f;

    public float animationRadius = 1.0f;
    
    [SerializeField] private Rigidbody2D rb;

    [SerializeField] private SpriteRenderer sr;

    [SerializeField] private Animator animator;

    private Direction direction;

    public Direction Direction
    {
        get => direction;

        set
        {
            direction = value;
            sr.flipX = direction == Direction.Left;
        }
    }
    
    private static readonly int PlayerPosID = Shader.PropertyToID("_PlayerPos");
    private static readonly int PlayerSightRadiusID = Shader.PropertyToID("_PlayerSightRadius");

    // Start is called before the first frame update
    void Start()
    {
    }

    void Update()
    {
        var axisX = Input.GetAxis("Horizontal");
        var xVelocity = axisX * horizontalSpeed;
        var yVelocity = Input.GetKeyDown(KeyCode.Space) ?  jumpForce : rb.velocity.y;
        rb.velocity = new Vector2(xVelocity, yVelocity);
        
        if (axisX > 0) Direction = Direction.Right;
        else if (axisX < 0) Direction = Direction.Left;
        
        if (yVelocity > 0) animator.Play("jump");
        else if (yVelocity < 0) animator.Play("fall");
        else if (Mathf.Abs(xVelocity) > 0) animator.Play("run");
        else animator.Play("idle");
        
        float radius = playerSightRadius + Mathf.Sin(Time.time * animationSpeed) * animationRadius;
        
        // Update shader global variable
        Shader.SetGlobalVector(PlayerPosID, transform.position);
        Shader.SetGlobalFloat(PlayerSightRadiusID, radius);;
    }
}
