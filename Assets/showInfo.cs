using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class showInfo : MonoBehaviour
{
    // Start is called before the first frame update
    public GameObject info;
    public bool active;
    void Start()
    {
        active = false;
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.I)){
            active = !active;
            info.SetActive(active);
        }
        
    }
}
