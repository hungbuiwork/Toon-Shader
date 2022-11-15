using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class splash : MonoBehaviour
{
    public bool colliding;
    public ParticleSystem splashParticle;
    // Start is called before the first frame update
    void Start()
    {
        colliding = false;
    }

    // Update is called once per frame
    void Update()
    {
        if (colliding){
            //splashParticle.Play();
        }
    }
    void OnCollisionEnter (Collision coll){
        if (coll.collider.gameObject.layer == LayerMask.NameToLayer("Water")){
            colliding = true;
            splashParticle.Play();
        }
    }
    void OnCollisionExit (Collision coll){
        if (coll.collider.gameObject.layer == LayerMask.NameToLayer("Water")){
            colliding = false;
        }
    }
}
