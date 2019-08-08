using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class Butterfly_Controller : MonoBehaviour 
{

	[SerializeField]
	public float HorizontalSpeed;

	[SerializeField]
	public float VerticalSpeed;

	[SerializeField]
	public float Amplitude;

	private Vector3 tempPosition;

	[SerializeField]
	public GameObject TheBF;

	[SerializeField]
	public bool IsDrone;

	[SerializeField]
	public float TerrainOffset;

	private float DroneTimer = 0;
	private Quaternion m_OriginalRotation;
	private Vector3 m_TargetAngles;
	public float rotationSpeed = 10;
	public Vector2 rotationRange = new Vector3(90, 361);
	private Vector3 m_FollowAngles;
	private Vector3 m_FollowVelocity;
	public float dampingTime = 0.2f;
	[SerializeField]
	public bool UseXBox ;

	void Start () 
	{
		Cursor.visible = false;
		tempPosition = transform.position;	
		m_OriginalRotation = transform.localRotation;
	}
	
	// Update is called once per frame
	void FixedUpdate () 
	{
		if(IsDrone == false)
		{
			if(UseXBox == true)
			{
			transform.localRotation = m_OriginalRotation;

			float inputH = Input.GetAxis("Mouse Xa");
			float inputV = Input.GetAxis("Mouse Ya");
			if (m_TargetAngles.y > 180)
			{
				m_TargetAngles.y -= 360;
				m_FollowAngles.y -= 360;
			}
			if (m_TargetAngles.x > 180)
			{
				m_TargetAngles.x -= 360;
				m_FollowAngles.x -= 360;
			}
			if (m_TargetAngles.y < -180)
			{
				m_TargetAngles.y += 360;
				m_FollowAngles.y += 360;
			}
			if (m_TargetAngles.x < -180)
			{
				m_TargetAngles.x += 360;
				m_FollowAngles.x += 360;
			}

			m_TargetAngles.y += inputH*rotationSpeed;
			m_TargetAngles.x += inputV*rotationSpeed;

			m_TargetAngles.y = Mathf.Clamp(m_TargetAngles.y, -rotationRange.y*0.5f, rotationRange.y*0.5f);
			m_TargetAngles.x = Mathf.Clamp(m_TargetAngles.x, -rotationRange.x*0.5f, rotationRange.x*0.5f);


			m_FollowAngles = Vector3.SmoothDamp(m_FollowAngles, m_TargetAngles, ref m_FollowVelocity, dampingTime);

			// update the actual gameobject's rotation
			transform.localRotation = m_OriginalRotation*Quaternion.Euler(-m_FollowAngles.x, m_FollowAngles.y, 0);

			}

			//transform.Rotate(new Vector3(0, Input.GetAxis("Mouse X"), 0) * Time.deltaTime * 90.0f);



			float Mod = HorizontalSpeed;
			if(Input.GetKey(KeyCode.LeftShift))
			{
				Mod = HorizontalSpeed + HorizontalSpeed;
			}

			if(Input.GetAxis("Vertical") > 0)
			{
				transform.Translate(Vector3.forward * Mod);


			}
			if(Input.GetAxis("Vertical") < 0)
			{
				transform.Translate((Vector3.back * Mod ) * 0.25f);

			}


			if(Input.GetAxis("Horizontal") < 0)
			{
				transform.Translate((Vector3.left/4) * Mod);
			}

			if(Input.GetAxis("Horizontal") > 0)
			{
				transform.Translate((Vector3.right/4) * Mod);
			}
			tempPosition= transform.position;
			float Vel = Mathf.Abs(Input.GetAxis("Horizontal")) + Mathf.Abs(Input.GetAxis("Vertical"));
			if(Vel > 0.0f)
			{
				tempPosition.y = (Mathf.Sin(Time.realtimeSinceStartup * VerticalSpeed) * Amplitude)  + (Terrain.activeTerrain.SampleHeight(transform.position) + TerrainOffset);
			}
			transform.position = tempPosition;

			if(Vel == 0.0f)
			{
				GetComponent<AudioSource>().Pause();
			}
			else
			{
				if(GetComponent<AudioSource>().isPlaying == false)
				{
					GetComponent<AudioSource>().Play();				
				}
			}

			GetComponent<Animator>().SetFloat("Speed",Vel);				
	

		}
		else
		{
			DroneTimer -= Time.deltaTime;
			if(DroneTimer <=0)
			{
				transform.Rotate(new Vector3(0.0f,Random.Range(0.0f,15.0f),0.0f));
				DroneTimer = 3.0f;
			}
			transform.Translate(Vector3.forward * 0.1f);
			tempPosition= transform.position;
			tempPosition.y = (Mathf.Sin(Time.realtimeSinceStartup * VerticalSpeed) * Amplitude)  + (Terrain.activeTerrain.SampleHeight(transform.position) + 1.4f);
			transform.position = tempPosition;
		}


	}
}
