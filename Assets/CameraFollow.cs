using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class CameraFollow : MonoBehaviour
{
    public GameObject player;
    public float cameraHeight = 20.0f;
    public Vector3 offset;
    public bool locked;
    void Awake()
    {
        locked = false;
        offset = transform.position - player.transform.position;
    }
    void Update()
    {
        //Vector3 pos = player.transform.position;
        //pos.z += cameraHeight;
        if (Input.GetKeyDown(KeyCode.Tab))
        {
            if (locked)
            {
                locked = !locked;
                offset = transform.position - player.transform.position;
            }
            else
            {
                locked = !locked;
            }
        }
        if (Input.GetKeyDown(KeyCode.R)){
            SceneManager.LoadScene(SceneManager.GetActiveScene().buildIndex);
        }
        if (!locked)
        {
            transform.position = offset + player.transform.position;
        }
    }
}