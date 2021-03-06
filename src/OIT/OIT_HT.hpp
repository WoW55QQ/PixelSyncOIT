//
// Created by christoph on 02.09.18.
//

#ifndef PIXELSYNCOIT_OIT_HT_HPP
#define PIXELSYNCOIT_OIT_HT_HPP

#include "OIT_Renderer.hpp"

#define HT_NUM_FRAGMENTS 8

// A fragment node stores rendering information about a list of fragments
/*struct HTFragmentNode_compressed
{
    // Linear depth, i.e. distance to viewer
    float depth[HT_NUM_FRAGMENTS];
    // RGB color (3 bytes), translucency (1 byte)
    uint32_t premulColor[HT_NUM_FRAGMENTS];
};
struct HTFragmentTail_compressed
{
    // Accumulated alpha (16 bit) and fragment count (16 bit)
    uint32_t accumAlphaAndCount;
    // RGB Color (30 bit, i.e. 10 bits per component)
    uint32_t accumColor;
};*/

/**
 * An order independent transparency renderer using pixel sync (i.e., ARB_fragment_shader_interlock).
 *
 * Marilena Maule, João Comba, Rafael Torchelsen, and Rui Bastos. 2013. Hybrid transparency. In Proceedings of the ACM
 * SIGGRAPH Symposium on Interactive 3D Graphics and Games (I3D '13). Association for Computing Machinery, New York, NY,
 * USA, 103–118. DOI:https://doi.org/10.1145/2448196.2448212
 */
class OIT_HT : public OIT_Renderer {
public:
    /**
     *  The gather shader is used to render our transparent objects.
     *  Its purpose is to store the fragments in an offscreen-buffer.
     */
    virtual sgl::ShaderProgramPtr getGatherShader() { return gatherShader; }

    OIT_HT();
    virtual void create();
    virtual void resolutionChanged(sgl::FramebufferObjectPtr &sceneFramebuffer, sgl::TexturePtr &sceneTexture,
            sgl::RenderbufferObjectPtr &sceneDepthRBO);

    virtual void gatherBegin();
    // In between "gatherBegin" and "gatherEnd", we can render our objects using the gather shader
    virtual void gatherEnd();

    // Blit accumulated transparent objects to screen
    virtual void renderToScreen();

    void renderGUI();
    void updateLayerMode();
    void reloadShaders();

    // For changing performance measurement modes
    void setNewState(const InternalState &newState);

private:
    void clear();
    void setUniformData();

    sgl::GeometryBufferPtr fragmentNodes;
    sgl::GeometryBufferPtr fragmentTails;

    // Blit data (ignores model-view-projection matrix and uses normalized device coordinates)
    sgl::ShaderAttributesPtr blitRenderData;
    sgl::ShaderAttributesPtr clearRenderData;

    sgl::FramebufferObjectPtr sceneFramebuffer;
    sgl::TexturePtr sceneTexture;
    sgl::RenderbufferObjectPtr sceneDepthRBO;

    bool clearBitSet;
};

#endif //PIXELSYNCOIT_OIT_HT_HPP
