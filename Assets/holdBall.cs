using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class holdBall : MonoBehaviour
{
    public GameObject ball;
    public bool holding;
    Vector3 offset;

    public ParticleSystem holdingParticle;
    public Rigidbody ballRB;
    public Rigidbody myRB;

    public GameObject water;
    public float throwscale;
    // Start is called before the first frame update
    void Start()
    {
        holding = false;
        offset = new Vector3(0f, 2f, 0f);
        ballRB = ball.GetComponent<Rigidbody>();
        myRB = GetComponent<Rigidbody>();
        throwscale = 60;
    }

    // Update is called once per frame
    void Update()
    {
        if (holding){
            ball.transform.position = transform.position + offset;
            holdingParticle.Play();
            //rigidbody. velocity = Vector3. zero;
            ballRB.velocity = myRB.velocity;
        }
        if (Input.GetKeyDown(KeyCode.E)){
            holding = !holding;
            if (!holding){
                ballRB.AddForce(throwscale*(water.transform.position - transform.position));
            }
        }
    
    }
}
